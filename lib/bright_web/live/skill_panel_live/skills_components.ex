defmodule BrightWeb.SkillPanelLive.SkillsComponents do
  use BrightWeb, :component

  import BrightWeb.SkillPanelLive.SkillPanelComponents, only: [score_mark_class: 2]
  import BrightWeb.BrightCoreComponents, only: [action_button: 1]
  import Phoenix.LiveView, only: [send_update: 2]

  alias Bright.SkillScores
  alias BrightWeb.SkillPanelLive.SkillsFieldComponent

  def compare_buttons(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center lg:flex-nowrap">
      <div class="flex gap-x-4">
        <.compare_individual current_user={@current_user} myself={@myself} />
        <.compare_team current_user={@current_user} myself={@myself} />
        <.compare_custom_group
          current_user={@current_user}
          custom_group={@custom_group}
          compared_users={@compared_users}
          myself={@myself}
          skills_field_id={@skills_field_id}
        />
      </div>
    </div>
    """
  end

  def compare_timeline(assigns) do
    ~H"""
    <div class="w-full mb-8 lg:mb-0 lg:mr-8 lg:max-w-[566px] lg:w-[566px]">
      <div class="flex flex-wrap justify-center lg:flex-nowrap lg:justify-start">
        <% # 過去方向ボタン %>
        <div class="flex justify-center items-center ml-1 mr-2">
          <%= if @timeline.past_enabled do %>
            <button
              class="w-6 h-10 bg-brightGreen-300 flex justify-center items-center rounded absolute left-4 lg:left-0 lg:relative hover:filter hover:brightness-[80%]"
              phx-click="shift_timeline_past"
              phx-target={@myself}
            >
              <span class="material-icons text-white !text-3xl">arrow_left</span>
            </button>
          <% else %>
            <button class="w-6 h-10 bg-brightGray-300 flex justify-center items-center rounded absolute left-4 lg:left-0 lg:relative">
              <span class="material-icons text-white !text-3xl">arrow_left</span>
            </button>
          <% end %>
        </div>

        <% # タイムラインバー %>
        <BrightWeb.TimelineBarComponents.timeline_bar
          id="timeline"
          target={@myself}
          type="myself"
          dates={@timeline.labels}
          selected_date={@timeline.selected_label}
          display_now={@timeline.display_now}
          scale="sm"
        />

        <% # 未来方向ボタン %>
        <div class="flex justify-center items-center ml-2">
          <%= if @timeline.future_enabled do %>
            <button
              class="w-6 h-10 bg-brightGreen-300 flex justify-center items-center rounded absolute right-4 lg:right-0 lg:relative hover:filter hover:brightness-[80%]"
              phx-click="shift_timeline_future"
              phx-target={@myself}
              disabled={!@timeline.future_enabled}
            >
              <span class="material-icons text-white !text-3xl">arrow_right</span>
            </button>
          <% else %>
            <button class="w-6 h-10 bg-brightGray-300 flex justify-center items-center rounded absolute right-4 lg:right-0 lg:relative">
              <span class="material-icons text-white !text-3xl">arrow_right</span>
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def compare_individual(assigns) do
    ~H"""
    <div
      id="compare-indivividual-dropdown"
      class="mt-4 lg:mt-0 hidden lg:block"
      phx-hook="Dropdown"
      data-dropdown-offset-skidding="307"
      data-dropdown-placement="bottom"
    >
      <.action_button icon="add" class="dropdownTrigger pl-3 py-1.5">
        <img class="mr-1" src="/images/common/icons/compareIndividual.svg" />
        <span class="min-w-[6em]">個人とスキルを比較</span>
      </.action_button>
      <div
        class="dropdownTarget bg-white rounded-md mt-1 w-[750px] bottom border-brightGray-100 border shadow-md hidden z-10"
      >
        <.live_component
          id="related-user-card-compare"
          module={BrightWeb.CardLive.RelatedUserCardComponent}
          current_user={@current_user}
          purpose="compare"
          card_row_click_target={@myself}
        />
      </div>
    </div>
    """
  end

  def compare_team(assigns) do
    ~H"""
    <div
      id="compare-team-dropdown"
      class="mt-4 lg:mt-0 hidden lg:block"
      phx-hook="Dropdown"
      data-dropdown-offset-skidding="290"
      data-dropdown-placement="bottom"
    >
      <.action_button icon="add" class="dropdownTrigger pl-3 py-1.5">
        <img class="mr-1" src="/images/common/icons/compareTeam.svg" />
        <span class="min-w-[6em]">チーム全員と比較</span>
      </.action_button>
      <div
        class="dropdownTarget bg-white rounded-md mt-1 w-[750px] border border-brightGray-100 shadow-md hidden z-10"
      >
        <.live_component
          id="related-team_card-compare"
          module={BrightWeb.CardLive.RelatedTeamCardComponent}
          display_user={@current_user}
          row_on_click_target={@myself}
          display_tabs={~w(joined_teams)}
        />
      </div>
    </div>
    """
  end

  def compare_custom_group(assigns) do
    ~H"""
    <div
      id="custom-group-dropdown"
      class="mt-4 lg:mt-0 hidden lg:block"
      phx-hook="Dropdown"
      data-dropdown-offset-skidding="110"
      data-dropdown-placement="bottom"
    >
      <.action_button icon="add" class="dropdownTrigger pl-3 py-1.5">
        <img class="mr-1" src="/images/common/icons/addCustomGroup.svg" />
        <span>カスタムグループ追加・比較</span>
      </.action_button>
      <div
        class="dropdownTarget z-10 hidden bg-white rounded-lg shadow-md min-w-[286px] border border-brightGray-50"
      >
        <.live_component
          id="compare-custom-group-menu"
          module={BrightWeb.SkillPanelLive.CompareCustomGroupMenuComponent}
          custom_group={@custom_group}
          current_user={@current_user}
          compared_users={@compared_users}
          on_create={&send_update(SkillsFieldComponent, id: @skills_field_id, custom_group_created: &1)}
          on_select={&send_update(SkillsFieldComponent, id: @skills_field_id, custom_group_selected: &1)}
          on_assign={&send_update(SkillsFieldComponent, id: @skills_field_id, custom_group_assigned: &1)}
          on_update={&send_update(SkillsFieldComponent, id: @skills_field_id, custom_group_updated: &1)}
          on_delete={&send_update(SkillsFieldComponent, id: @skills_field_id, custom_group_deleted: &1)}
        />
      </div>
    </div>

    <div :if={@custom_group} id="selected-custom-group-name" class="text-left flex items-center text-base">
      <img
        src="/images/common/icons/coustom_group.svg"
        class="!flex w-6 h-6 mr-1 !items-center !justify-center"
        />
      <%= @custom_group.name %>
    </div>
    """
  end

  def skills_table(assigns) do
    ~H"""
    <div id="skills-table-field" class="h-[70vh] overflow-auto scroll-pt-[76px] mt-4 h-[50vh]">
      <table class="skill-panel-table">
        <% # z-[1]: table内のsticky優先表示で使用 %>
        <thead>
          <tr>
            <td colspan="4" class="sticky z-[1] left-0 top-0 min-w-[900px] bg-white sticky-border"> </td>
            <td class="sticky top-0 bg-white sticky-border sticky-border-plus-top">
              <div class="flex justify-center items-center min-w-[80px] min-w-[150px]">
                <p class="inline-flex flex-1 justify-center">
                  <%= if(@anonymous, do: "非表示", else: @display_user.name) %>
                </p>
              </div>
            </td>
            <td :for={user <- @compared_users} class="sticky top-0 bg-white sticky-border sticky-border-plus-top">
              <div class="flex justify-center items-center">
                <p class="inline-flex flex-1 justify-center"><%= if user.anonymous, do: "非表示", else: user.name %></p>
                <button
                  type="button"
                  class="text-brightGray-900 rounded-full w-3 h-3 inline-flex items-center justify-center"
                  phx-click="reject_compared_user"
                  phx-target={@myself}
                  phx-value-name={user.name}
                >
                  <span class="material-icons-outlined !text-xs">close</span>
                </button>
              </div>
            </td>
          </tr>
          <tr>
            <th class="bg-base text-white text-center min-w-[200px] sticky z-[1] left-0 top-[37px] sticky-border sticky-border-plus-left">
              知識エリア
            </th>
            <th class="bg-base text-white text-center min-w-[200px] sticky z-[1] left-[200px] top-[37px] sticky-border">
              カテゴリー
            </th>
            <th class="bg-base text-white text-center min-w-[420px] sticky z-[1] left-[400px] top-[37px] sticky-border">
              スキル
            </th>
            <th class="bg-base text-white text-center min-w-[80px] sticky z-[1] left-[820px] top-[37px] sticky-border">
              合計
            </th>
            <td id="my-percentages" class="bg-white sticky top-[37px] sticky-border">
              <div class="flex justify-center flex-wrap gap-x-2">
                <div class="min-w-[3em] flex items-center">
                  <span class={[score_mark_class(:high, :green), "inline-block mr-1"]} />
                  <span class="score-high-percentage"><%= SkillScores.calc_high_skills_percentage(@counter.high, @num_skills) %>％</span>
                </div>
                <div class="min-w-[3em] flex items-center">
                  <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]} />
                  <span class="score-middle-percentage"><%= SkillScores.calc_middle_skills_percentage(@counter.middle, @num_skills) %>％</span>
                </div>
              </div>
            </td>
            <td
              :for={{user, index} <- Enum.with_index(@compared_users, 1)}
              id={"user-#{index}-percentages"}
              class="bg-white sticky top-[37px] sticky-border"
            >
              <% user_data = Map.get(@compared_user_dict, user.name) %>
              <div class="flex justify-center gap-x-2">
                <div class="min-w-[3em] flex items-center">
                  <span class={[score_mark_class(:high, :amethyst), "inline-block mr-1"]}></span>
                  <span class="score-high-percentage"><%= user_data.high_skills_percentage %>％</span>
                </div>
                <div class="min-w-[3em] flex items-center">
                  <span class={[score_mark_class(:middle, :amethyst), "inline-block mr-1"]}></span>
                  <span class="score-middle-percentage"><%= user_data.middle_skills_percentage %>％</span>
                </div>
              </div>
            </td>
          </tr>
        </thead>

        <%= for {[col1, col2, col3], row} <- @table_structure |> Enum.with_index(1) do %>
          <% skill_score = @skill_score_dict[col3.skill.id] %>
          <% current_skill = Map.get(@current_skill_dict, col3.skill.trace_id, %{}) %>
          <% current_skill_score = Map.get(@current_skill_score_dict, Map.get(current_skill, :id)) %>

          <tr id={"skill-#{row}"}>
            <td :if={col1} rowspan={col1.size} id={"unit-#{col1.position}"} class="align-top sticky left-0 bg-white sticky-border sticky-border-plus-left">
              <%= col1.skill_unit.name %>
            </td>
            <td :if={col2} rowspan={col2.size} class="align-top sticky left-[200px] bg-white sticky-border">
              <%= col2.skill_category.name %>
            </td>
            <td class="sticky left-[400px] bg-white sticky-border">
              <div class="flex justify-between items-center">
                <p><%= col3.skill.name %></p>
                <div :if={map_size(current_skill) > 0} class="flex justify-between items-center gap-x-2">
                  <.skill_evidence_link  path={~p"/panels/#{@skill_panel}/skills/#{current_skill}/evidences?#{@query}"}  skill_score={current_skill_score} />
                  <.skill_reference_link :if={@me} path={~p"/panels/#{@skill_panel}/skills/#{current_skill}/reference?#{@query}"}  skill={current_skill} skill_score={current_skill_score}  />
                  <.skill_exam_link :if={@me} path={~p"/panels/#{@skill_panel}/skills/#{current_skill}/exam?#{@query}"} skill={current_skill} skill_score={current_skill_score} />
                </div>
              </div>
            </td>
            <td class="sticky left-[820px] bg-white sticky-border">
              <div class="num-high-users flex justify-center gap-x-1">
                <div class="min-w-[3em] flex items-center">
                  <span class={[score_mark_class(:high, :gray), "inline-block mr-1"]}></span>
                  <%= if Map.get(skill_score, :score) == :high do %>
                    <%= get_in(@compared_users_stats, [col3.skill.id, :high_skills_count]) + 1 %>
                  <% else %>
                    <%= get_in(@compared_users_stats, [col3.skill.id, :high_skills_count]) %>
                  <% end %>
                </div>
                <div class="min-w-[3em] flex items-center">
                  <span class={[score_mark_class(:middle, :gray), "inline-block mr-1"]}></span>
                  <%= if Map.get(skill_score, :score) == :middle do %>
                    <%= get_in(@compared_users_stats, [col3.skill.id, :middle_skills_count]) + 1 %>
                  <% else %>
                    <%= get_in(@compared_users_stats, [col3.skill.id, :middle_skills_count]) %>
                  <% end %>
                </div>
              </div>
            </td>
            <td>
              <div class="flex justify-center gap-x-4 px-4 h-[21px] items-center">
                <span class={[score_mark_class(skill_score.score, :green), "inline-block", "score-mark-#{skill_score.score}"]} />
              </div>
            </td>
            <td :for={user <- @compared_users}>
              <% score = get_in(@compared_user_dict, [user.name, :skill_score_dict, col3.skill.id]) %>
              <div class="flex justify-center gap-x-4 px-4 h-[21px] items-center">
                <span class={[score_mark_class(score, :amethyst), "inline-block"]} />
              </div>
            </td>
          </tr>
        <% end %>
      </table>

      <%= if @num_skills == 0 do %>
        <div class="mt-28 w-full flex flex-col justify-center items-center gap-y-2">
          <p class="text-2xl lg:text-4xl">データ未登録の区間です。</p>
          <p class="text-md lg:text-xl">スキル入力された以降の区間を選択するとスキル一覧／習得状況が表示されます。</p>
        </div>
      <% end %>
    </div>
    """
  end

  def skills_table_sp(assigns) do
    ~H"""
    <div id="skills-table-field-sp" class="flex justify-center items-center mb-20">
      <section class="text-sm w-full">
        <div>
          <%= for {skill_unit, position} <- Enum.with_index(@skill_units, 1) do %>
            <b id={"unit-#{position}-sp"} class="block font-bold mt-6 text-xl">
              <%= skill_unit.name %>
            </b>
            <%= for skill_category <- get_children(skill_unit, "skill_categories") do %>
              <div class="category-top">
                <b class="block font-bold mt-2 text-base">
                  <%= skill_category.name %>
                </b>

                <table class="mt-2 w-full">
                  <%= for skill <- get_children(skill_category, "skills") do %>
                    <% skill_score = @skill_score_dict[skill.id] || %{score: :low} %>
                    <% current_skill = Map.get(@current_skill_dict, skill.trace_id, %{}) %>
                    <% current_skill_score = Map.get(@current_skill_score_dict, Map.get(current_skill, :id)) %>

                    <tr
                      id={"skill-sp-#{skill.id}"}
                      class={["border border-brightGray-200"]}
                    >
                      <th class="flex justify-between align-middle w-full mb-2 min-h-8 p-2 text-left">
                        <span class="break-words max-w-[172px]"><%= skill.name %></span>
                        <div class="flex justify-end items-center gap-x-2 min-w-[80px]">
                          <.skill_evidence_link path={"panels"} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                          <.skill_reference_link :if={@me} path={"panels"} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                          <.skill_exam_link :if={@me} path={"panels"} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                        </div>
                      </th>

                      <td class="align-middle border-l border-brightGray-200 p-2 w-12">
                        <div class="flex justify-center gap-x-1">
                          <span class={[score_mark_class(skill_score.score, :green), "inline-block", "score-mark-#{skill_score.score}"]} />
                        </div>
                      </td>
                    </tr>
                  <% end %>
                </table>
              </div>
            <% end %>
          <% end %>
        </div>
      </section>
    </div>
    """
  end

  defp get_children(unit_or_category, attr) do
    Map.get(
      unit_or_category,
      String.to_atom(attr),
      Map.get(unit_or_category, String.to_atom("historical_#{attr}"), [])
    )
  end

  def skill_evidence_link(%{skill_score: nil} = assigns), do: ~H""

  def skill_evidence_link(assigns) do
    ~H"""
    <.link class="link-evidence" patch={@path}>
      <%= if @skill_score.evidence_filled do %>
        <img src="/images/common/icons/skillEvidenceActive.svg" />
      <% else %>
        <img src="/images/common/icons/skillEvidence.svg" />
      <% end %>
    </.link>
    """
  end

  def skill_reference_link(%{skill_score: nil} = assigns), do: ~H""

  def skill_reference_link(assigns) do
    ~H"""
    <.link :if={skill_reference_existing?(@skill.skill_reference)} class="link-reference" patch={@path}>
      <%= if @skill_score.reference_read do %>
        <img src="/images/common/icons/skillStudyActive.svg" />
      <% else %>
        <img src="/images/common/icons/skillStudy.svg" />
      <% end %>
    </.link>
    """
  end

  def skill_exam_link(%{skill_score: nil} = assigns), do: ~H""

  def skill_exam_link(assigns) do
    ~H"""
    <.link :if={skill_exam_existing?(@skill.skill_exam)} class="link-exam" patch={@path}>
      <%= if @skill_score.exam_progress in [:wip, :done] do %>
        <img src="/images/common/icons/skillTestActive.svg" />
      <% else %>
        <img src="/images/common/icons/skillTest.svg" />
      <% end %>
    </.link>
    """
  end

  defp skill_reference_existing?(skill_reference) do
    skill_reference && skill_reference.url
  end

  defp skill_exam_existing?(skill_exam) do
    skill_exam && skill_exam.url
  end
end
