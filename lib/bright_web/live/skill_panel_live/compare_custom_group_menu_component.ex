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
    <ul class="p-2 text-left text-base">
      <li>
        <a class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer">
          下記の人たちでカスタムグループを更新する
        </a>
      </li>
      <li>
        <div
          id="custom-groups-list-dropdown"
          class="mt-4 lg:mt-0 hidden lg:block"
          phx-hook="Dropdown"
          data-dropdown-placement="right-start"
        >
          <button
            class="dropdownTrigger w-full flex items-center justify-between block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
            type="button"
          >
            別のカスタムグループに切り替える
            <svg class="w-2.5 h-2.5 ml-2.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 6 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 9 4-4-4-4"/>
            </svg>
          </button>
          <div
            class="dropdownTarget bg-white rounded-md mt-1 border border-brightGray-100 shadow-md hidden z-10"
          >
            <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="doubleDropdownButton">
              <li>
                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Overview</a>
              </li>
              <li>
                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">My downloads</a>
              </li>
              <li>
                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Billing</a>
              </li>
            </ul>
          </div>
        </div>
      </li>
      <li>
        <.form
          for={@form}
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
     |> assign_form(CustomGroups.change_custom_group(%CustomGroups.CustomGroup{}))}
  end

  def handle_event("create", %{"custom_group" => params}, socket) do
    %{
      current_user: current_user,
      compared_users: compared_users,
      on_create: on_create
    } = socket.assigns
    member_users_params = build_member_users_params(compared_users)

    params = Map.merge(params, %{
      "user_id" => current_user.id,
      "member_users" => member_users_params
    })

    CustomGroups.create_custom_group(params)
    |> case do
      {:ok, custom_group} ->
        on_create.(custom_group)
        {:noreply, assign(socket, :custom_group, custom_group)}
      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp build_member_users_params(compared_users) do
    compared_users
    |> Enum.reject(& &1.anonymous)
    |> Enum.with_index(1)
    |> Enum.map(fn {user, position} ->
      %{user_id: user.id, position: position}
    end)
  end
end
