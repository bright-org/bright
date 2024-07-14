defmodule BrightWeb.SkillPanelLive.GrowthShareModalComponent do
  @moduledoc """
  成長をシェアする際に表示するモーダル
  """

  use BrightWeb, :live_component

  import BrightWeb.BrightModalComponents

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
        show
      >
        <.header>ナイス ブライト！</.header>
        <div class="mt-4">
          <p><%= @user.name %> さんの最近の活動です</p>

          <hr class="my-2" />

          <.skill_class_level_record_message
            skill_class={@skill_class}
            skill_class_score={@skill_class_score}
            historical_skill_class_score={@historical_skill_class_score} />

          <.skill_units_record_message user={@user} skill_class={@skill_class} />
        </div>

        <SnsComponents.sns_share_button_group :if={false} />
        ＜ここにシェアボタン とりあえずkoyoさん作成のものにする＞
      </.bright_modal>
    </div>
    """
  end

  def update(%{open: true} = assigns, socket) do
    user = Accounts.get_user!(assigns.user_id)
    skill_class = SkillPanels.get_skill_class!(assigns.skill_class_id)
    skill_panel = SkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    # スキルクラスも取る
    # 現状と3か月前を比べての成果も出す
    {:ok,
      socket
      |> assign(:open, true)
      |> assign(:user, user)
      |> assign(:skill_class, skill_class)
      |> assign(:skill_panel, skill_panel)
      |> assign_presents()
      |> assign_historicals()}
  end

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(:open, false)}
  end

  defp assign_presents(socket) do
    %{user: user, skill_class: skill_class} = socket.assigns
    skill_class_score = SkillScores.get_skill_class_score_by(user_id: user.id, skill_class_id: skill_class.id)
    skill_unit_scores = SkillScores.list_skill_unit_scores_by_user_skill_class(user, skill_class)

    assign(socket,
      skill_class_score: skill_class_score,
      skill_unit_scores: skill_unit_scores)
  end

  defp assign_historicals(socket) do
    %{user: user, skill_class: skill_class} = socket.assigns
    date = TimelineHelper.get_prev_date_from_now()

    historical_skill_class_score = HistoricalSkillScores.get_historical_skill_class_score_by_user_skill_class(user, skill_class, date)
    historical_skill_unit_scores = []

    assign(socket,
      historical_skill_class_score: historical_skill_class_score,
      historical_skill_unit_scores: historical_skill_unit_scores)
  end

  # private components

  defp skill_class_level_record_message(%{skill_class_score: nil} = assigns) do
    ~H""
  end

  defp skill_class_level_record_message(%{
    skill_class_score: %{level: level_before},
    historical_skill_class_score: %{level: level_after}
  } = assigns) when level_before == level_after do
    # レベルアップ変化がない場合には非表示
    ~H""
  end


  defp skill_class_level_record_message(%{historical_skill_class_score: nil} = assigns) do
    # TODO: レベルの日本語化
    ~H"""
    <p>
      「<%= @skill_class.name %>」のレベルを「<%= @skill_class_score.level %>」からスタートしました！
    </p>
    """
  end

  defp skill_class_level_record_message(assigns) do
    # TODO: レベルの日本語化
    ~H"""
    <p>
      「<%= @skill_class.name %>」のレベルが「<%= @historical_skill_class_score.level %>」から「<%= @skill_class_score.level %>」にアップしました！
    </p>
    """
  end

  defp skill_units_record_message(%{skill_unit_scores: []} = assigns) do
    ~H""
  end

  defp skill_units_record_message(assigns) do
    ~H""
  end
end
