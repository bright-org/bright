defmodule BrightWeb.SkillPanelLive.CompareCustomGroupMenuComponent do
  @moduledoc """
  カスタムグループの追加、選択用のLiveComponent

  NOTE:
  dropdown内で追加を行う必要があり、処理によってdropdownが閉じる点と検証メッセージを出す点の相性が悪いため、LiveComponentとして切り出している。また処理も切り離すことで肥大化を避けている。
  """

  use BrightWeb, :live_component

  alias Bright.CustomGroups
  alias BrightWeb.BrightCoreComponents

  def render(assigns) do
    ~H"""
    <ul class="w-96 p-2 text-left text-base">

      <% # カスタムグループ名表示および変更と削除 %>
      <li :if={@custom_group} class="flex items-center justify-between">
        <div :if={is_nil(@form_update)} class="text-left flex items-center text-base py-3">
          <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-1 !items-center !justify-center">group</span>
          <%= @custom_group.name %>
        </div>

        <div :if={is_nil(@form_update)}>
          <button
            id="btn-custom-group-update"
            class="grow-0 text-sm font-bold px-3 py-2 rounded border bg-base text-white"
            phx-click="mode_update"
            phx-target={@myself}
          >
            更新
          </button>
          <button
            id="btn-custom-group-delete"
            class="grow-0 text-sm font-bold px-3 py-2 rounded border bg-base text-white"
            phx-click="delete"
            phx-target={@myself}
          >
            削除
          </button>
        </div>

        <div :if={@form_update} class="w-full flex items-center">
          <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-1 !items-center !justify-center">group</span>
          <.form
            id="form-custom-group-update"
            for={@form_update}
            class="flex items-center space-x-2 py-2"
            phx-submit="update"
            phx-target={@myself}
          >
            <div class="grow">
              <BrightCoreComponents.input type="text" input_class="w-full" field={@form_update[:name]} />
            </div>
            <button class="grow-0 text-sm font-bold px-3 py-2 rounded border bg-base text-white">保存</button>
          </.form>
        </div>
      </li>

      <% # カスタムグループメンバーの更新 %>
      <li :if={@custom_group}>
        <div
          class="px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
          phx-click="assign"
          phx-target={@myself}
        >
          下記の人たちでカスタムグループを更新する
        </div>
      </li>

      <% # カスタムグループの切り替え %>
      <li>
        <div
          id="custom-groups-list-dropdown"
          class="mt-2"
          phx-hook="Dropdown"
          data-dropdown-placement="right-start"
        >
          <button
            class="dropdownTrigger w-full flex items-center justify-between block px-1 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
            type="button"
          >
            <%= if @custom_group do %>
              別のカスタムグループに切り替える
            <% else %>
              カスタムグループに切り替える
            <% end %>
            <svg class="w-2.5 h-2.5 ml-2.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 6 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 9 4-4-4-4"/>
            </svg>
          </button>
          <div
            class="dropdownTarget bg-white rounded-md mt-1 border border-brightGray-100 shadow-md hidden z-10"
          >
            <ul class="py-2 text-sm text-base">
              <li :for={custom_group <- @custom_groups}>
                <div
                  class="px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
                  phx-click="select"
                  phx-target={@myself}
                  phx-value-name={custom_group.name}
                >
                  <%= custom_group.name %>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </li>

      <% # カスタムグループの新規作成 %>
      <li>
        <.form
          for={@form}
          id="form-custom-group-create"
          class="flex items-center space-x-2 py-2"
          phx-submit="create"
          phx-target={@myself}
        >
          <div class="grow">
            <BrightCoreComponents.input type="text" input_class="w-full" field={@form[:name]} placeholder="下記の人たちでカスタムグループを追加する" />
          </div>
          <button class="grow-0 text-sm font-bold px-3 py-2 rounded border bg-base text-white">追加</button>
        </.form>
      </li>
    </ul>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(custom_group: nil)
     |> assign(form_update: nil)
     |> assign_form()}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:custom_groups, list_custom_groups(assigns.current_user))}
  end

  def handle_event("create", %{"custom_group" => params}, socket) do
    %{
      current_user: current_user,
      compared_users: compared_users,
      on_create: on_create
    } = socket.assigns

    member_users_params = build_member_users_params(compared_users)

    params =
      Map.merge(params, %{
        "user_id" => current_user.id,
        "member_users" => member_users_params
      })

    CustomGroups.create_custom_group(params)
    |> case do
      {:ok, custom_group} ->
        on_create.(custom_group)

        {:noreply,
         socket
         |> assign(:custom_group, custom_group)
         |> assign_form()}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("update", %{"custom_group" => params}, socket) do
    %{custom_group: custom_group, on_update: on_update} = socket.assigns

    CustomGroups.update_custom_group(custom_group, params)
    |> case do
      {:ok, custom_group} ->
        on_update.(custom_group)

        {:noreply,
         socket
         |> assign(:custom_group, custom_group)
         |> assign(:form_update, nil)}

      {:error, changeset} ->
        {:noreply, assign_form_update(socket, changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    %{custom_group: custom_group, on_delete: on_delete} = socket.assigns
    CustomGroups.delete_custom_group(custom_group)
    on_delete.(custom_group)
    {:noreply, assign(socket, :custom_group, nil)}
  end

  def handle_event("select", %{"name" => name}, socket) do
    %{custom_groups: custom_groups, on_select: on_select} = socket.assigns
    custom_group = Enum.find(custom_groups, &(&1.name == name))
    on_select.(custom_group)

    {:noreply, socket}
  end

  def handle_event("assign", _params, socket) do
    %{
      compared_users: compared_users,
      custom_group: custom_group,
      on_assign: on_assign
    } = socket.assigns

    member_users_params = build_member_users_params(compared_users)
    custom_group = Bright.Repo.preload(custom_group, :member_users, force: true)
    params = %{"member_users" => member_users_params}
    {:ok, _} = CustomGroups.update_custom_group(custom_group, params)
    on_assign.(custom_group)

    {:noreply, socket}
  end

  def handle_event("mode_update", _params, socket) do
    changeset = CustomGroups.change_custom_group(socket.assigns.custom_group)
    {:noreply, assign_form_update(socket, changeset)}
  end

  defp assign_form(socket) do
    assign_form(socket, CustomGroups.change_custom_group(%CustomGroups.CustomGroup{}))
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_form_update(socket, changeset) do
    assign(socket, :form_update, to_form(changeset))
  end

  defp build_member_users_params(compared_users) do
    compared_users
    |> Enum.reject(& &1.anonymous)
    |> Enum.with_index(1)
    |> Enum.map(fn {user, position} ->
      %{user_id: user.id, position: position}
    end)
  end

  defp list_custom_groups(user) do
    CustomGroups.list_user_custom_groups(user.id)
  end
end
