defmodule BrightWeb.MypageLive.MypageComponent do
  use BrightWeb, :component

  import BrightWeb.SkillEvidenceComponents

  alias Bright.SkillEvidences
  alias BrightWeb.PathHelper
  alias Bright.SkillScores

  def js_show_my_field(js \\ %JS{}) do
    js
    |> JS.remove_class("button-toggle-active", to: "#btn-others-field")
    |> JS.hide(to: "#others-field")
    |> JS.add_class("button-toggle-active")
    |> JS.show(to: "#my-field")
  end

  def js_show_others_field(js \\ %JS{}) do
    js
    |> JS.remove_class("button-toggle-active", to: "#btn-my-field")
    |> JS.hide(to: "#my-field")
    |> JS.add_class("button-toggle-active")
    |> JS.show(to: "#others-field")
  end

  # local components
  # ---

  def skill_ups(assigns) do
    ~H"""
    <section>
      <h5 class="text-base lg:text-lg">スキルアップ</h5>
      <div
        :if={@recent_level_up_skill_class_scores == []}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
      >
        まだスキルを選択していません
      </div>

      <div class="bg-white rounded-md mt-1 px-2 py-0.5">
        <ul class="text-sm font-medium text-center gap-y-2">
          <li
            :for={skill_class_score <- @recent_level_up_skill_class_scores}
            class="flex flex-wrap my-2"
          >
            <.link
              class="cursor-pointer hover:filter hover:brightness-[80%] text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap"
              href={skill_panel_path(skill_class_score, @display_user, @me, @anonymous)}
            >
              <img src="/images/common/icons/skill.svg" class="w-6 h-6 mr-2.5">
              <span class="order-3 lg:order-2 flex-1 mr-2">
                <%= skill_up_message(skill_class_score) %>
              </span>
            </.link>
            <%= format_datetime(skill_up_datetime(skill_class_score), "Asia/Tokyo", "%Y-%m-%d") %>
          </li>
        </ul>
      </div>
    </section>
    """
  end

  def others_skill_evidences(assigns) do
    ~H"""
    <section>
      <h5 class="text-base lg:text-lg flex gap-x-2">
        いま学んでいます
        <img src="/images/common/icons/skillEvidenceActive.svg" />
      </h5>
      <div
        :for={skill_evidence <- @recent_others_skill_evidences}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2 flex flex-col"
      >
        <div class="flex">
          <.skill_evidence
            skill_evidence={skill_evidence}
            skill_evidence_post={get_latest_my_skill_evidence_post(skill_evidence)}
            skill_breadcrumb={SkillEvidences.get_skill_breadcrumb(%{id: skill_evidence.skill_id})}
            current_user={@current_user}
            anonymous={@anonymous}
            related_user_ids={@related_user_ids}
            display_time={false}
          />
        </div>
      </div>
      <div class="bg-white rounded-md px-2 py-2 my-2 text-sm font-medium">
        <.link navigate={~p"/notifications/evidences"}>
          「学習メモのヘルプ」をみる
        </.link>
      </div>
    </section>
    """
  end

  def get_latest_my_skill_evidence_post(skill_evidence) do
    # 「いま学んでいます」では自分自身の最新投稿を参照する
    skill_evidence.skill_evidence_posts
    |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
    |> Enum.find(&(&1.user_id == skill_evidence.user_id))
  end

  def skill_panel_path(skill_class_score, display_user, me, anonymous) do
    %{skill_class: %{class: class, skill_panel: skill_panel}} = skill_class_score

    PathHelper.skill_panel_path("graphs", skill_panel, display_user, me, anonymous) <>
      "?class=#{class}"
  end

  def skill_up_message(skill_class_score) do
    %{
      level: level,
      skill_class: %{
        name: skill_class_name,
        class: class,
        skill_panel: %{
          name: skill_panel_name
        }
      }
    } = skill_class_score

    level_name = Gettext.gettext(BrightWeb.Gettext, "level_#{level}")

    case {class, level} do
      {1, :beginner} ->
        "#{skill_panel_name}【#{skill_class_name}】を始めました"

      _ ->
        "#{skill_panel_name}【クラス#{class}：#{skill_class_name}】が「#{level_name}」にレベルアップしました"
    end
  end

  def skill_up_datetime(skill_class_score) do
    SkillScores.get_skill_class_score_action_timestamp(skill_class_score)
  end
end
