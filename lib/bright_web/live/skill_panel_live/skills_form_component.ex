defmodule BrightWeb.SkillPanelLive.SkillsFormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillScores
  alias BrightWeb.CardLive.SkillCardComponent

  # キーボード入力 1,2,3 と対応するスコア
  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

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
      <section class="text-sm w-[390px]">
        <h2 class="font-bold mt-4 mb-2 text-lg truncate">
          <span class="before:bg-bgGem before:bg-5 before:bg-left before:bg-no-repeat before:content-[''] before:h-5 before:inline-block before:relative before:top-[2px] before:w-5">
            <%= @skill_panel.name %>
            <%= SkillScores.count_user_skill_scores(@user) %>
          </span>
        </h2>

        <div id={"#{@id}-scroll"} class="h-[644px] overflow-y-auto" phx-hook="ScrollOccupancy">
          <%= for skill_unit <- @skill_units do %>
            <b class="block font-bold mt-6 text-xl">
              <%= skill_unit.name %>
            </b>

            <%= for skill_category <- skill_unit.skill_categories do %>
              <div class="category-top">
                <b class="block font-bold mt-2 text-base">
                  <%= skill_category.name %>
                </b>

                <table class="mt-2 w-[350px]">
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
                              name={"score-#{row}-1"}
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
                              name={"score-#{row}-1"}
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
                              name={"score-#{row}-1"}
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
      |> put_flash_next_skill_class_open(updated_result, skill_class_score.id)
      |> put_flash_first_time_submit()
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

  defp update_by_score_change(socket, skill_score, score) do
    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_dict =
      socket.assigns.skill_score_dict
      |> Map.put(skill_score.skill_id, %{skill_score | score: score, changed: true})

    assign(socket, :skill_score_dict, skill_score_dict)
  end

  defp assign_first_time(socket) do
    # スキルを初めて入力したときのメッセージ表示用のフラグ管理
    # 無駄な処理を省くため、簡易判定後に正確な判定処理を実行
    %{user: user, skill_class: skill_class, skill_score_dict: skill_score_dict} = socket.assigns
    skill_scores = Map.values(skill_score_dict)
    maybe_first_time = skill_class.class == 1 && Enum.all?(skill_scores, & &1.id == nil)
    first_time = maybe_first_time && SkillScores.count_user_skill_scores(user) == 0

    assign(socket, :first_time, first_time)
  end

  defp maybe_update_skill_card_component(skill_class_score) do
    prev_level = skill_class_score.level
    skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
    new_level = skill_class_score.level

    if prev_level != new_level do
      send_update(SkillCardComponent, id: "skill_card", status: "level_changed")
    end
  end

  # スキルクラス解放時のみメッセージ表示のためflashを設定
  defp put_flash_next_skill_class_open(socket, updated_result, skill_class_score_id) do
    get_in(updated_result, [
      :skill_class_scores,
      :"skill_class_score_#{skill_class_score_id}",
      :next_skill_class_score
    ])
    |> if(do: put_flash(socket, :next_skill_class_open, true), else: socket)
  end

  # スキルを初めて入力したときのみメッセージ表示のためflashを設定
  defp put_flash_first_time_submit(socket) do
    socket.assigns.first_time
    |> if(do: put_flash(socket, :first_time_submit, true), else: socket)
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
end
