defmodule BrightWeb.NotificationLive.Evidence do
  use BrightWeb, :live_view

  alias Bright.Notifications
  alias Bright.SkillEvidences
  alias Bright.SkillUnits
  alias BrightWeb.CardLive.CardListComponents
  alias BrightWeb.TabComponents

  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @default_page 1
  @page_per 10

  @impl true
  def render(assigns) do
    ~H"""
    <div id="notification_evidence_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <li :if={Enum.count(@notifications) == 0} class="flex">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
          学習メモの通知はありません
          </div>
        </li>
        <%= for notification <- @notifications do %>
          <li class="flex flex-wrap my-5">
            <div phx-click="click" phx-value-notification_evidence_id={notification.id} class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate">
              <span class="material-icons text-lg text-white bg-brightGreen-300 rounded-full flex w-6 h-6 mr-2.5 items-center justify-center">
                person
              </span>
              <span class={["order-3 lg:order-2 flex-1 mr-2 truncate"]}><%= notification.message %></span>
              <CardListComponents.elapsed_time inserted_at={notification.inserted_at} />
            </div>
            <div class="flex gap-x-2 w-full justify-end lg:justify-start lg:w-auto">
              <button phx-click="click" phx-value-notification_evidence_id={notification.id} class="hidden hover:opacity-70 font-bold lg:inline-block bg-brightGray-900 text-white min-w-[76px] rounded p-2 text-sm">
                内容を見る
              </button>
            </div>
          </li>
        <% end %>
        <TabComponents.tab_footer id="notification_evidence_footer" page={@page} total_pages={@total_pages} target={"#notification_evidence_container"} />
      </div>
    </div>

    <% # 学習メモ用モーダル %>
    <%= if :show == @live_action do %>
      <.bright_modal
        :if={!@show_denied}
        id="notification_evidence_modal"
        style_of_modal_flame_out="w-full max-w-3xl p-4 sm:p-6 lg:py-8"
        show
        on_cancel={JS.patch(~p"/notifications/evidences")}>

        <.live_component
          module={BrightWeb.SkillPanelLive.SkillEvidenceComponent}
          id={"#{@skill.id}-evidence"}
          skill={@skill}
          skill_evidence={@skill_evidence}
          user={@current_user}
          anonymous={false}
          me={@skill_evidence.user_id == @current_user.id}
        />
      </.bright_modal>

      <.bright_modal
        :if={@show_denied}
        id="notification_evidence_modal_show_denied"
        style_of_modal_flame_out="w-full max-w-3xl p-4 sm:p-6 lg:py-8"
        show
        on_cancel={JS.patch(~p"/notifications/evidences")}>
        <p>現在は表示できない学習メモです。</p>
      </.bright_modal>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "学習メモの通知")
    |> assign_on_page(@default_page)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"skill_evidence_id" => skill_evidence_id}) do
    skill_evidence =
      SkillEvidences.get_skill_evidence!(skill_evidence_id)
      |> Bright.Repo.preload(:user)

    # 現在も対応可能な学習メモか確認
    SkillEvidences.can_write_skill_evidence?(skill_evidence, socket.assigns.current_user)
    |> if do
      skill = SkillUnits.get_skill!(skill_evidence.skill_id)

      socket
      |> assign(:skill, skill)
      |> assign(:skill_evidence, skill_evidence)
      |> assign(:show_denied, false)
    else
      assign(socket, :show_denied, true)
    end
  end

  defp apply_action(socket, _live_action, _params), do: socket

  @impl true
  def handle_event("previous_button_click", _params, socket) do
    socket
    |> assign_on_page(socket.assigns.page - 1)
    |> then(&{:noreply, &1})
  end

  def handle_event("next_button_click", _params, socket) do
    socket
    |> assign_on_page(socket.assigns.page + 1)
    |> then(&{:noreply, &1})
  end

  def handle_event("click", %{"notification_evidence_id" => id} = _params, socket) do
    notification = find_notification(socket.assigns.notifications, id)

    socket
    |> push_patch(to: notification.url)
    |> then(&{:noreply, &1})
  end

  # ---private---

  defp get_notifications(user_id, page, per) do
    Notifications.list_notification_by_type(
      user_id,
      "evidence",
      page: page,
      page_size: per
    )
  end

  defp find_notification(notifications, notification_evidence_id) do
    Enum.find(notifications, &(&1.id == notification_evidence_id))
  end

  defp assign_on_page(socket, page) do
    %{entries: notifications, total_pages: total_pages} =
      get_notifications(socket.assigns.current_user.id, page, @page_per)

    socket
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> assign(:notifications, notifications)
  end
end
