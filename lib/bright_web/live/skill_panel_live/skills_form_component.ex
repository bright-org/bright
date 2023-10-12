defmodule BrightWeb.SkillPanelLive.SkillsFormComponent do
  use BrightWeb, :live_component

  import BrightWeb.ChartComponents, only: [doughnut_graph: 1]

  import BrightWeb.SkillPanelLive.SkillPanelComponents,
    only: [profile_skill_class_level: 1, score_mark_class: 2, skill_score_percentages: 2]

  import BrightWeb.SkillPanelLive.SkillsComponents,
    only: [enter_skills_help_message: 1]

  import BrightWeb.SkillPanelLive.SkillPanelHelper,
    only: [calc_percentage: 2, count_skill_scores: 1]

  alias Bright.SkillScores
  alias BrightWeb.CardLive.SkillCardComponent

  # キーボード入力 1,2,3 と対応するスコア
  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  # 入力時間目安表示のための１スキルあたりの時間(分): 約20秒
  @minute_per_skill 0.33

  # スコアと対応するHTML class属性
  @score_mark_class %{
    "high" =>
      "bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:h-4 before:w-4 before:rounded-full before:bg-brightGray-300 before:block peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:opacity-50",
    "middle" =>
      "bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:h-0 before:w-0 before:border-solid before:border-t-0 before:border-r-8 before:border-l-8 before:border-transparent before:border-b-[14px] before:border-b-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:border-b-white hover:opacity-50",
    "low" =>
      "bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:block before:w-4 before:h-1 before:bg-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:opacity-50"
  }

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex justify-center items-center">
      <section class="text-sm w-full lg:w-[390px]">
        <h2 class="flex items-center gap-x-4 font-bold mt-6 mb-2 text-lg truncate">
          <span class="before:bg-bgGem before:bg-5 before:bg-left before:bg-no-repeat before:content-[''] before:h-5 before:inline-block before:relative before:top-[2px] before:w-5">
            <%= @skill_panel.name %>
          </span>

          <div
            id="btn-help-enter-skills-modal"
            class="flex-none cursor-pointer"
            phx-click={JS.push("open", target: "#help-enter-skills-modal") |> show("#help-enter-skills-modal")}>
            <img class="w-8 h-8" src="/images/icon_help.svg" />
          </div>
        </h2>

        <% # スキル入力するモーダル 手動表示メッセージ %>
        <% # NOTE: idはGAイベントトラッキング対象、変更の際は確認と共有必要 %>
        <.live_component
          module={BrightWeb.HelpMessageComponent}
          id="help-enter-skills-modal"
          open={false}>
          <.enter_skills_help_message reference_from={"modal"} />
        </.live_component>

        <p class="text-attention-900 p-2 text-sm">
          セッション制限時間の1時間以内に「保存する」ボタンを押してください。
        </p>

        <% # ドーナツグラフとレベル表記 %>
        <div id="doughnut_area_in_skills_form" class="flex items-center my-4">
          <div class="basis-3/4 flex justify-center">
            <.doughnut_graph id="doughnut_graph_in_skills_form" data={skill_score_percentages(@counter, @num_skills)} />
            <div class="flex justify-center items-center ml-2">
              <div class="flex flex-col">
                <p class="text-brightGreen-300 font-bold w-full flex mt-1 mb-1">
                  <.profile_skill_class_level level={get_level(@counter, @num_skills)} />
                </p>
                <div class="flex items-center pl-6">
                  <span class={[score_mark_class(:high, :green), "inline-block mr-1"]}></span>
                  <span class="score-high-percentage"><%= calc_percentage(@counter.high, @num_skills) %>％</span>
                </div>
                <div class="flex items-center mt-1 pl-6">
                  <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]}></span>
                  <span class="score-middle-percentage"><%= calc_percentage(@counter.middle, @num_skills) %>％</span>
                </div>
              </div>
            </div>
          </div>
          <div class="basis-1/4 flex flex-col items-end mr-6">
            <p class="text-xs font-bold">スキル数</p>
            <p class="text-sm"><%= @num_skills %></p>
            <p class="text-xs font-bold">入力目安</p>
            <p class="text-sm"><%= round(minute_per_skill() * @num_skills) %>分</p>
          </div>
        </div>

        <div id={"#{@id}-scroll"} class="h-[400px] lg:h-[600px] overflow-y-auto">
          <%= for skill_unit <- @skill_units do %>
            <b class="block font-bold mt-6 text-xl">
              <%= skill_unit.name %>
            </b>

            <%= for skill_category <- skill_unit.skill_categories do %>
              <div class="category-top">
                <b class="block font-bold mt-2 text-base">
                  <%= skill_category.name %>
                </b>

                <table class="mt-2 w-full lg:w-[350px]">
                  <%= for skill <- skill_category.skills do %>
                    <% row = Map.get(@row_dict, skill.id) %>
                    <% focus = row == @focus_row %>
                    <% skill_score = @skill_score_dict[skill.id] %>
                    <tr
                      id={"skill-#{row}-form"}
                      class={[focus && "bg-brightGray-50", "border border-brightGray-200"]}
                    >
                      <th class="align-middle w-[250px] mb-2 min-h-8 p-2 text-left">
                        <%= skill.name %>
                      </th>

                      <td class="align-middle border-l border-brightGray-200 p-2">
                        <div
                          class="flex gap-1"
                          phx-window-keydown={focus && "shortcut"}
                          phx-target={@myself}
                          phx-throttle="1000"
                          phx-value-skill_id={skill.id}
                        >
                          <label
                            class="inline"
                            phx-click="change"
                            phx-target={@myself}
                            phx-value-score="high"
                            phx-value-skill_id={skill.id}
                          >
                            <input
                              type="radio"
                              name={"score-#{row}"}
                              checked={skill_score.score == :high}
                              class="hidden peer"
                            />
                            <span class={Map.get(score_mark_class(), "high")}></span>
                          </label>

                          <label
                            class="inline"
                            phx-click="change"
                            phx-target={@myself}
                            phx-value-score="middle"
                            phx-value-skill_id={skill.id}
                          >
                            <input
                              type="radio"
                              name={"score-#{row}"}
                              checked={skill_score.score == :middle}
                              class="hidden peer"
                            />
                            <span class={Map.get(score_mark_class(), "middle")}></span>
                          </label>

                          <label
                            class="inline"
                            phx-click="change"
                            phx-target={@myself}
                            phx-value-score="low"
                            phx-value-skill_id={skill.id}
                          >
                            <input
                              type="radio"
                              name={"score-#{row}"}
                              checked={skill_score.score == :low}
                              class="hidden peer"
                            />
                            <span class={Map.get(score_mark_class(), "low")}></span>
                          </label>
                        </div>
                      </td>
                    </tr>
                  <% end %>
                </table>
              </div>
            <% end %>
          <% end %>
        </div>

        <div class="flex justify-center gap-x-4 mt-4 pb-2 relative w-full">
          <button
            class="text-sm font-bold px-2 py-2 rounded border bg-base text-white w-60"
            phx-click="submit"
            phx-target={@myself}
          >
            保存する
          </button>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :focus_row, 1)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_skill_units()
     |> assign_row_dict()
     |> assign_counter()
     |> assign_first_time()}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    %{
      user: user,
      skill_class_score: skill_class_score,
      skill_score_dict: skill_score_dict
    } = socket.assigns

    target_skill_scores = skill_score_dict |> Map.values() |> Enum.filter(& &1.changed)
    {:ok, updated_result} = SkillScores.insert_or_update_skill_scores(target_skill_scores, user)

    # スキルクラスのレベル変更時に保有スキルカードの表示変更を通知
    maybe_update_skill_card_component(skill_class_score)

    {:noreply,
     socket
     |> put_flash_next_skill_class_opened(updated_result, skill_class_score.id)
     |> put_flash_first_submit_in_overall()
     |> put_flash_first_submit_in_skill_panel()
     |> push_patch(to: socket.assigns.patch)}
  end

  def handle_event("change", %{"score" => score, "skill_id" => skill_id}, socket) do
    score = String.to_atom(score)
    skill_score = Map.get(socket.assigns.skill_score_dict, skill_id)
    row = Map.get(socket.assigns.row_dict, skill_id)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> assign(:focus_row, row)}
  end

  def handle_event("shortcut", %{"key" => key, "skill_id" => skill_id}, socket)
      when key in ~w(1 2 3) do
    score = Map.get(@shortcut_key_score, key)
    skill_score = Map.get(socket.assigns.skill_score_dict, skill_id)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.num_skills]))
     |> push_scroll_to()}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowDown Enter) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.num_skills]))
     |> push_scroll_to()}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowUp) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.max([1, &1 - 1]))
     |> push_scroll_to()}
  end

  def handle_event("shortcut", _params, socket) do
    {:noreply, socket}
  end

  defp assign_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(skill_units: [skill_categories: [:skills]])
      |> Map.get(:skill_units)

    assign(socket, :skill_units, skill_units)
  end

  defp assign_row_dict(socket) do
    # 指定行をハイライトすることなどのためのUI便宜上の準備
    dict =
      socket.assigns.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)
      |> Enum.with_index(1)
      |> Map.new(fn {skill, row} -> {skill.id, row} end)

    socket
    |> assign(:row_dict, dict)
    |> assign(:num_skills, Enum.count(dict))
  end

  defp assign_counter(socket) do
    counter = count_skill_scores(socket.assigns.skill_score_dict)
    assign(socket, :counter, counter)
  end

  defp update_by_score_change(socket, skill_score, score) do
    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_dict =
      socket.assigns.skill_score_dict
      |> Map.put(skill_score.skill_id, %{skill_score | score: score, changed: true})

    socket
    |> assign(:skill_score_dict, skill_score_dict)
    |> assign_counter()
  end

  defp assign_first_time(socket) do
    # スキルを初めて入力したときのメッセージ表示用のフラグ管理
    %{user: user, skill_class: skill_class, skill_score_dict: skill_score_dict} = socket.assigns
    skill_scores = Map.values(skill_score_dict)
    first_time_in_skill_panel = skill_class.class == 1 && Enum.all?(skill_scores, &(&1.id == nil))

    first_time_overall =
      first_time_in_skill_panel && !SkillScores.get_user_entered_skill_score_at_least_one?(user)

    socket
    |> assign(:first_time_in_overall, first_time_overall)
    |> assign(:first_time_in_skill_panel, first_time_in_skill_panel)
  end

  defp maybe_update_skill_card_component(skill_class_score) do
    prev_level = skill_class_score.level
    skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
    new_level = skill_class_score.level

    if prev_level != new_level do
      send_update(SkillCardComponent, id: "skill_card", status: "level_changed")
    end
  end

  # スキルクラス解放時のメッセージ表示のためflashを設定
  defp put_flash_next_skill_class_opened(socket, updated_result, skill_class_score_id) do
    get_in(updated_result, [
      :skill_class_scores,
      :"skill_class_score_#{skill_class_score_id}",
      :next_skill_class_score
    ])
    |> if(do: put_flash(socket, :next_skill_class_opened, true), else: socket)
  end

  # スキル初回入力（全体初）後に表示するメッセージのためのflashを設定
  defp put_flash_first_submit_in_overall(socket) do
    socket.assigns.first_time_in_overall
    |> if(do: put_flash(socket, :first_submit_in_overall, true), else: socket)
  end

  # スキル初回入力（本スキルパネル初）後に表示するメッセージのためのflashを設定
  defp put_flash_first_submit_in_skill_panel(socket) do
    socket.assigns.first_time_in_skill_panel
    |> if(do: put_flash(socket, :first_submit_in_skill_panel, true), else: socket)
  end

  defp push_scroll_to(socket) do
    %{focus_row: row} = socket.assigns
    # キーショートカットによる入力時スクロール
    push_event(socket, "scroll-to-parent", %{
      target: "skill-#{row}-form",
      parent_selector: ".category-top"
    })
  end

  defp score_mark_class, do: @score_mark_class

  defp get_level(counter, num_skills) do
    percentage = calc_percentage(counter.high, num_skills)
    SkillScores.get_level(percentage)
  end

  defp minute_per_skill, do: @minute_per_skill
end
