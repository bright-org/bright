defmodule BrightWeb.GraphLive.Graphs do
  use BrightWeb, :live_view

  alias Bright.SkillPanels.SkillPanel
  alias Bright.Teams
  alias Bright.Accounts
  alias Bright.UserJobProfiles
  alias BrightWeb.ProfileComponents
  alias BrightWeb.GuideMessageComponents
  alias BrightWeb.SnsComponents
  alias Bright.UserSkillPanels
  alias BrightWeb.Share.Helper, as: ShareHelper

  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper
  import BrightWeb.NextLevelAnnounceComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def mount(params, _session, socket) do
    socket
    |> assign_display_user(params)
    |> assign_skill_panel(params["skill_panel_id"])
    |> assign(:select_label, "now")
    |> assign(:compared_user, nil)
    |> assign(:select_label_compared_user, nil)
    |> assign(:page_title, "成長パネル")
    |> assign(:open_income_consultation, false)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, url, %{assigns: %{skill_panel: %SkillPanel{}}} = socket) do
    # TODO: データ取得方法検討／LiveVIewコンポーネント化検討
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_skill_classes()
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_compared_user(params["compare"])
     |> ShareHelper.assign_share_graph_url()
     |> touch_user_skill_panel()}
  end

  def handle_params(_params, _url, %{assigns: %{skill_panel: nil}} = socket),
    do: {:noreply, socket}

  @impl true
  def handle_event("click_on_related_user_card_menu", params, socket) do
    skill_panel = socket.assigns.skill_panel

    {user, anonymous} =
      get_user_from_name_or_name_encrypted(params["name"], params["encrypt_user_name"])

    get_path_to_switch_display_user("graphs", user, skill_panel, anonymous)
    |> case do
      {:ok, path} ->
        {:noreply, push_redirect(socket, to: path)}

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "選択された対象者がスキルパネルを保有していないため、対象者を表示できません")}
    end
  end

  def handle_event("clear_display_user", _params, socket) do
    %{current_user: current_user, skill_panel: skill_panel} = socket.assigns
    move_to = get_path_to_switch_me("graphs", current_user, skill_panel)

    {:noreply, push_redirect(socket, to: move_to)}
  end

  def handle_event("open_income_consultation", _params, socket) do
    {:noreply, assign(socket, :open_income_consultation, true)}
  end

  def handle_event("close_income_consultation", _params, socket) do
    {:noreply, assign(socket, :open_income_consultation, false)}
  end

  def handle_event("click_skill_star_button", _params, %{assigns: assigns} = socket) do
    is_star = !assigns.is_star

    socket =
      socket
      |> assign(:is_star, is_star)

    UserSkillPanels.set_is_star(assigns.display_user, assigns.skill_panel, is_star)
    {:noreply, socket}
  end

  def handle_event("growth_graph_data_click", %{"value" => value}, socket) do
    [_, value] = String.split(value, ",")
    value = Base.decode64!(value)
    socket = assign(socket, :growth_graph_data, value)
    upload_growth_graph_data(socket.assigns, "./test.png")
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event_name: "timeline_bar_button_click", params: %{"id" => "myself", "date" => date}},
        socket
      ) do
    {:noreply, assign(socket, :select_label, date)}
  end

  def handle_info(
        %{event_name: "timeline_bar_button_click", params: %{"id" => "other", "date" => date}},
        socket
      ) do
    {:noreply, assign(socket, :select_label_compared_user, date)}
  end

  def handle_info(%{event_name: "compared_user_added", params: params}, socket) do
    %{"compared_user" => compared_user, "select_label" => select_label} = params

    {:noreply,
     socket
     |> assign(:compared_user, compared_user)
     |> assign(:select_label_compared_user, select_label)}
  end

  def handle_info(%{event_name: "compared_user_deleted"}, socket) do
    {:noreply,
     socket
     |> assign(:compared_user, nil)
     |> assign(:select_label_compared_user, nil)}
  end

  def assign_compared_user(socket, nil), do: socket

  def assign_compared_user(socket, user_name) do
    compared_user = Accounts.get_user_by_name!(user_name) |> Map.put(:anonymous, false)

    Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
      socket.assigns.current_user.id,
      compared_user.id
    )

    socket
    |> assign(:compared_user, compared_user)
    |> assign(:select_label_compared_user, "now")
  end

  # NOTE: スキル入力後メッセージ（初回のみ）
  def help_messages_area(assigns) do
    ~H"""
    <div class="lg:absolute lg:left-0 lg:top-16 lg:z-10 flex items-center lg:items-end flex-col lg:min-w-[600px]">
      <% # NOTE: idはGAイベントトラッキング対象、変更の際は確認と共有必要 %>
      <.live_component
        :if={Map.get(@flash, "first_submit_in_overall")}
        module={BrightWeb.HelpMessageComponent}
        id="help-first-skill-submit-in-overall">
        <GuideMessageComponents.first_submit_in_overall_message />
      </.live_component>
    </div>
    """
  end

  defp upload_growth_graph_data(assigns, file_name) do
    growth_graph_data = assigns.growth_graph_data
    File.write(file_name, growth_graph_data)
  end
end
