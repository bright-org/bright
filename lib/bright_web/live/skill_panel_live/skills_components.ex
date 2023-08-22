defmodule BrightWeb.SkillPanelLive.SkillsComponents do
  use BrightWeb, :component

  import BrightWeb.SkillPanelLive.SkillPanelComponents, only: [score_mark_class: 2]
  import BrightWeb.SkillPanelLive.SkillPanelHelper, only: [calc_percentage: 2]

  def compares(assigns) do
    ~H"""
    <div class="flex mt-4 items-center">
      <.compare_timeline myself={@myself} timeline={@timeline} />
      <div class="flex gap-x-4">
        <.compare_individual current_user={@current_user} myself={@myself} />
        <% # TODO: α版後にifを除去して表示 %>
        <.compare_team :if={false} current_user={@current_user} />
        <% # TODO: α版後にifを除去して表示 %>
        <.compare_custom_group :if={false} />
      </div>
    </div>
    """
  end

  def compare_timeline(assigns) do
    ~H"""
    <div class="w-[566px] mr-10">
      <div class="flex">
        <% # 過去方向ボタン %>
        <div class="flex justify-center items-center ml-1 mr-3">
          <%= if @timeline.past_enabled do %>
            <button
              class="w-6 h-8 bg-brightGray-900 flex justify-center items-center rounded"
              phx-click="shift_timeline_past"
              phx-target={@myself}
            >
              <span class="material-icons text-white !text-3xl">arrow_left</span>
            </button>
          <% else %>
            <button class="w-6 h-8 bg-brightGray-300 flex justify-center items-center rounded">
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
              class="w-6 h-8 bg-brightGray-900 flex justify-center items-center rounded"
              phx-click="shift_timeline_future"
              phx-target={@myself}
              disabled={!@timeline.future_enabled}
            >
              <span class="material-icons text-white !text-3xl">arrow_right</span>
            </button>
          <% else %>
            <button class="w-6 h-8 bg-brightGray-300 flex justify-center items-center rounded">
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
    <button
      id="addCompareDropdownButton-related-user"
      data-dropdown-toggle="addCompareDropdown-related-user"
      data-dropdown-offset-skidding="300"
      data-dropdown-placement="bottom"
      class="border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
      type="button"
    >
      <span class="min-w-[6em]">個人と比較</span>
      <span
        class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
        >add</span>
    </button>
    <!-- 個人と比較Donwdrop -->
    <div
      class="bg-white rounded-md mt-1 w-[750px] bottom border-brightGray-100 border shadow-md hidden"
      id="addCompareDropdown-related-user"
    >
      <.live_component
        id="related-user-card-compare"
        module={BrightWeb.CardLive.RelatedUserCardComponent}
        current_user={@current_user}
        display_menu={false}
        purpose="compare"
        card_row_click_target={@myself}
      />
    </div>
    """
  end

  def compare_team(assigns) do
    ~H"""
    <button
      id="compareAllDropdownButton"
      data-dropdown-toggle="compareAllDropdown"
      data-dropdown-offset-skidding="300"
      data-dropdown-placement="bottom"
      class="border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
      type="button"
    >
      <span class="min-w-[6em]">チーム全員と比較</span>
      <span
        class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
        >add</span>
    </button>
    <!-- チーム全員と比較Downdrop -->
    <div
      class="bg-white rounded-md mt-1 w-[750px] border border-brightGray-100 shadow-md hidden"
      id="compareAllDropdown"
    >
      <.live_component
        id="related_team_card_compare"
        module={BrightWeb.CardLive.RelatedTeamCardComponent}
        current_user={@current_user}
        show_menu={false}
      />
    </div>
    """
  end

  def compare_custom_group(assigns) do
    ~H"""
    <button
      id="addCustomGroupDropwonButton"
      data-dropdown-toggle="addCustomGroupDropwon"
      data-dropdown-offset-skidding="230"
      data-dropdown-placement="bottom"
      type="button"
      class="text-brightGray-600 bg-white px-2 py-2 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
    >
      カスタムグループ
    </button>
    <!-- カスタムグループDropdown -->
    <div
      id="addCustomGroupDropwon"
      class="z-10 hidden bg-white rounded-lg shadow-md min-w-[286px] border border-brightGray-50"
    >
      <ul
        class="p-2 text-left text-base"
        aria-labelledby="dropmenu04"
      >
        <li>
          <a
            data-modal-target="defaultModal"
            data-modal-toggle="defaultModal"
            class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
          >
            下記をカスタムグループとして追加する
          </a>
        </li>
        <li>
          <a
            href="#"
            class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
            >下記で現在のカスタムグループを更新する</a>
        </li>
      </ul>
    </div>

    <!-- カスタムグループ福岡Elixir -->
    <div class="text-left flex items-center text-base">
      <span
        class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-1 !items-center !justify-center"
        >group</span>
      カスタムグループ福岡Elixir
    </div>
    """
  end

  def skills_table(assigns) do
    ~H"""
    <div class="mt-4">
      <table class="table-fixed skill-panel-table border-t border-l border-brightGray-200">
        <tr>
          <td colspan="4" class="!border-t !border-l-white !border-t-white !border-l">
          </td>
          <td class="!border-l !border-brightGray-200">
            <div class="flex justify-center items-center min-w-[150px]">
              <p class="inline-flex flex-1 justify-center">
                <%= if(@anonymous, do: "非表示", else: @display_user.name) %>
              </p>

              <%= if @editable do %>
                <button
                  :if={not @edit}
                  type="button"
                  class="bg-brightGreen-300 hover:bg-brightGray-100 rounded-full w-5 h-5 inline-flex items-center justify-center"
                  phx-click="edit"
                >
                  <span class="material-icons-outlined text-white hover:text-brightGray-900 !text-sm">edit</span>
                </button>
                <button
                  :if={@edit}
                  type="button"
                  class="bg-brightGreen-300 hover:bg-brightGray-100 rounded-full w-5 h-5 inline-flex items-center justify-center"
                  phx-click="submit"
                >
                  <span class="material-symbols-outlined text-white hover:text-brightGray-900 !text-sm">cloud_done</span>
                </button>
              <% end %>
            </div>
          </td>
          <td :for={user <- @compared_users} class="!border-l !border-brightGray-200">
            <div class="flex justify-center items-center">
              <p class="inline-flex flex-1 justify-center"><%= user.name %></p>
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
          <th class="bg-base text-white text-center w-[200px]">
            知識エリア
          </th>
          <th class="bg-base text-white text-center w-[200px]">
            カテゴリー
          </th>
          <th class="bg-base text-white text-center w-[420px]">
            スキル
          </th>
          <th class="bg-base text-white text-center">
            合計
          </th>
          <td>
            <div class="flex justify-center gap-x-2">
              <div class="min-w-[3em] flex items-center">
                <span class={[score_mark_class(:high, :green), "inline-block mr-1"]} />
                <span class="score-high-percentage"><%= floor calc_percentage(@counter.high, @num_skills) %>％</span>
              </div>
              <div class="min-w-[3em] flex items-center">
                <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]} />
                <span class="score-middle-percentage"><%= floor calc_percentage(@counter.middle, @num_skills) %>％</span>
              </div>
            </div>
          </td>
          <td :for={user <- @compared_users}>
            <% user_data = Map.get(@compared_user_dict, user.name) %>
            <div class="flex justify-center gap-x-2">
              <div class="min-w-[3em] flex items-center">
                <span class={[score_mark_class(:high, :amethyst), "inline-block mr-1"]}></span><%= user_data.high_skills_percentage %>％
              </div>
              <div class="min-w-[3em] flex items-center">
                <span class={[score_mark_class(:middle, :amethyst), "inline-block mr-1"]}></span><%= user_data.middle_skills_percentage %>％
              </div>
            </div>
          </td>
        </tr>

        <%= for {[col1, col2, col3], row} <- @table_structure |> Enum.with_index(1) do %>
          <% focus = @focus_row == row %>
          <% skill_score = @skill_score_dict[col3.skill.id] %>
          <% current_skill = Map.get(@current_skill_dict, col3.skill.trace_id) %>
          <% current_skill_score = Map.get(@current_skill_score_dict, Map.get(current_skill, :id)) %>

          <tr id={"skill-#{row}"} class="focus:bg-brightGray-100">
            <td :if={col1} rowspan={col1.size} id={"unit-#{col1.position}"} class="align-top">
              <%= col1.skill_unit.name %>
            </td>
            <td :if={col2} rowspan={col2.size} class="align-top">
              <%= col2.skill_category.name %>
            </td>
            <td class={[focus && "bg-brightGray-50"]}>
              <div class="flex justify-between items-center">
                <p><%= col3.skill.name %></p>
                <div class="flex justify-between items-center gap-x-2">
                  <.skill_evidence_link skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                  <.skill_reference_link :if={@me} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                  <.skill_exam_link :if={@me} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                </div>
              </div>
            </td>
            <td>
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
            <td class={[focus && "bg-brightGray-50"]}>
              <%= if @edit do %>
                <div
                  class="flex justify-center gap-x-4 px-4"
                  phx-window-keydown={focus && "shortcut"}
                  phx-throttle="1000"
                  phx-value-skill_id={col3.skill.id}
                >
                  <label
                    class="block flex items-center"
                    phx-click="change"
                    phx-value-score="high"
                    phx-value-skill_id={col3.skill.id}
                    phx-value-row={row}
                  >
                    <input
                      type="radio"
                      name={"score-#{row}-1"}
                      checked={skill_score.score == :high}
                      class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600" />
                    <span class={[score_mark_class(:high, :green), "ml-1"]} />
                  </label>

                  <label
                    class="block flex items-center"
                    phx-click="change"
                    phx-value-score="middle"
                    phx-value-skill_id={col3.skill.id}
                    phx-value-row={row}
                  >
                    <input
                      type="radio"
                      name={"score-#{row}-2"}
                      checked={skill_score.score == :middle}
                      class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600" />
                    <span class={[score_mark_class(:middle, :green), "ml-1"]} />
                  </label>

                  <label
                    class="block flex items-center"
                    phx-click="change"
                    phx-value-score="low"
                    phx-value-skill_id={col3.skill.id}
                    phx-value-row={row}
                  >
                    <input
                      type="radio"
                      name={"score-#{row}-3"}
                      checked={skill_score.score == :low}
                      class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 hark:bg-gray-700 dark:border-gray-600" />
                    <span class={[score_mark_class(:low, :green), "ml-1"]} />
                  </label>
                </div>
              <% else %>
                <div class="flex justify-center gap-x-4 px-4 min-w-[150px]">
                  <span class={[score_mark_class(skill_score.score, :green), "inline-block", "score-mark-#{skill_score.score}"]} />
                </div>
              <% end %>
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
    </div>
    """
  end

  def skill_evidence_link(%{skill_score: nil} = assigns), do: ~H""

  def skill_evidence_link(assigns) do
    ~H"""
    <.link class="link-evidence" patch={~p"/panels/#{@skill_panel}/skills/#{@skill}/evidences?#{@query}"}>
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
    <.link :if={skill_reference_existing?(@skill.skill_reference)} class="link-reference" patch={~p"/panels/#{@skill_panel}/skills/#{@skill}/reference?#{@query}"}>
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
    <.link :if={skill_exam_existing?(@skill.skill_exam)} class="link-exam" patch={~p"/panels/#{@skill_panel}/skills/#{@skill}/exam?#{@query}"}>
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
