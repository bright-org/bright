defmodule BrightWeb.SkillPanelLive.GrowthShareModalComponent do
  @moduledoc """
  成長をシェアする際に表示するモーダル
  """

  use BrightWeb, :live_component

  import BrightWeb.BrightModalComponents
  import BrightWeb.BrightGraphComponents

  alias BrightWeb.SnsComponents
  alias BrightWeb.TimelineHelper

  alias Bright.Accounts
  alias Bright.SkillPanels
  alias Bright.SkillScores
  alias Bright.HistoricalSkillScores

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.bright_modal
        id={"#{@id}_modal"}
        :if={@open}
        on_cancel={JS.push("close", target: @myself)}
        show
      >
        <.header>ナイス ブライト！</.header>

        <div class="my-4 min-w-80">
          <div class="flex flex-col gap-y-2">
            <.skill_class_level_record_message
              skill_class={@skill_class}
              skill_class_score={@skill_class_score}
              historical_skill_class_score={@historical_skill_class_score} />

            <div class="flex flex-col gap-y-1 mt-4 mb-2">
              <.skill_units_record_message
                skill_unit_scores={@skill_unit_scores}
                historical_skill_unit_scores={@historical_skill_unit_scores}
                date_from={@date_from} />
            </div>
            <div class="lg:flex lg:flex-row">
              <.triangle_graph data={@prev_skill_share_data} id="triangle_graph_past"/>
              <div class="w-[75px] ml-[65px] mb-[5px] flex flex-col justify-center lg:ml-0 lg:block">
                <span class="text-lg">Level Up!</span>
                <span class="hidden lg:inline material-icons text-7xl">arrow_right_alt</span>
                <span class="lg:hidden material-icons text-7xl">arrow_downward</span>
              </div>
              <.triangle_graph data={@skill_share_data} id="triangle_graph"/>
            </div>
          </div>
        </div>

        <SnsComponents.sns_share_button_group share_graph_url={@share_graph_url} skill_panel={@skill_panel.name} level_text={@level_text} />
      </.bright_modal>
    </div>
    """
  end

  def update(%{open: true} = assigns, socket) do
    user = Accounts.get_user!(assigns.user_id)
    skill_class = SkillPanels.get_skill_class!(assigns.skill_class_id)
    skill_panel = SkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    skill_share_data =
      SkillScores.get_level_count_from_skill_panel_id(skill_panel.id, skill_class.class)
      |> Map.merge(%{name: skill_panel.name, level: assigns.new_level})

    prev_skill_share_data =
      assigns.prev_skill_share_data
      |> Map.merge(%{level: assigns.prev_level})

    # スキルクラスも取る
    # 現状と3か月前を比べての成果も出す
    {:ok,
     socket
     |> assign(:open, true)
     |> assign(:user, user)
     |> assign(:skill_class, skill_class)
     |> assign(:skill_panel, skill_panel)
     |> assign(:skill_share_data, skill_share_data)
     |> assign(:prev_skill_share_data, prev_skill_share_data)
     |> assign_presents()
     |> assign_historicals()}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:open, false)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :open, false)}
  end

  defp assign_presents(socket) do
    %{user: user, skill_class: skill_class} = socket.assigns

    skill_class_score =
      SkillScores.get_skill_class_score_by(user_id: user.id, skill_class_id: skill_class.id)

    skill_unit_scores = SkillScores.list_skill_unit_scores_by_user_skill_class(user, skill_class)

    level_text = get_level_text(skill_class_score.level)

    assign(socket,
      skill_class_score: skill_class_score,
      skill_unit_scores: skill_unit_scores,
      level_text: level_text
    )
  end

  defp assign_historicals(socket) do
    %{user: user, skill_class: skill_class, skill_unit_scores: skill_unit_scores} = socket.assigns
    date_from = TimelineHelper.get_prev_date_from_now()
    skill_units = Enum.map(skill_unit_scores, & &1.skill_unit)

    historical_skill_class_score =
      HistoricalSkillScores.get_historical_skill_class_score_by_user_skill_class(
        user,
        skill_class,
        date_from
      )

    historical_skill_unit_scores =
      HistoricalSkillScores.list_historical_skill_unit_scores_by_user_skill_units(
        user,
        skill_units,
        date_from
      )

    assign(socket,
      date_from: date_from,
      historical_skill_class_score: historical_skill_class_score,
      historical_skill_unit_scores: historical_skill_unit_scores
    )
  end

  # private components

  defp skill_class_level_record_message(%{skill_class_score: nil} = assigns) do
    ~H""
  end

  defp skill_class_level_record_message(
         %{
           skill_class_score: %{level: level_after},
           historical_skill_class_score: %{level: level_before}
         } = assigns
       )
       when level_before == level_after do
    # 履歴データがあってレベル変化がない場合には非表示
    ~H""
  end

  defp skill_class_level_record_message(%{historical_skill_class_score: nil} = assigns) do
    ~H"""
    <p>
      「<%= @skill_class.name %>」のレベルを「<%= get_level_text(@skill_class_score.level) %>」からスタートしました！
    </p>
    """
  end

  defp skill_class_level_record_message(assigns) do
    ~H"""
    <p>
      「<%= @skill_class.name %>」のレベルが「<%= get_level_text(@historical_skill_class_score.level) %>」から「<%= get_level_text(@skill_class_score.level) %>」にアップしました！
    </p>
    """
  end

  defp skill_units_record_message(%{skill_unit_scores: []} = assigns) do
    ~H""
  end

  defp skill_units_record_message(assigns) do
    ~H"""
    <p><%= Calendar.strftime(@date_from, "%Y-%m-%d") %> からの道のり</p>

    <div :for={{skill_unit_score, index} <- Enum.with_index(@skill_unit_scores)}>
      <.skill_unit_record_message
        skill_unit_score={skill_unit_score}
        historical_skill_unit_score={Enum.at(@historical_skill_unit_scores, index)} />
    </div>
    """
  end

  defp skill_unit_record_message(%{historical_skill_unit_score: nil} = assigns) do
    ~H"""
    <p>
      ・<%= @skill_unit_score.skill_unit.name %>： <%= get_percentage(@skill_unit_score) %> New！
    </p>
    """
  end

  defp skill_unit_record_message(assigns) do
    ~H"""
    <p>
      ・<%= @skill_unit_score.skill_unit.name %>： <%= get_percentage(@historical_skill_unit_score) %> → <%= get_percentage(@skill_unit_score) %>
    </p>
    """
  end

  defp get_percentage(score) do
    score.percentage
    |> floor()
    |> then(&"#{&1}%")
  end

  defp get_level_text(level) do
    Gettext.gettext(BrightWeb.Gettext, "level_#{level}")
  end
end
