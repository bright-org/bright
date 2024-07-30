defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view

  import BrightWeb.ProfileComponents
  import BrightWeb.ChartComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  alias Bright.SkillScores
  alias BrightWeb.PathHelper
  alias BrightWeb.DisplayUserHelper

  @impl true
  def mount(params, _session, socket) do
    socket
    |> DisplayUserHelper.assign_display_user(params)
    |> assign(:page_title, "保有スキル")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "保有スキル")
    |> assign_skillset_gem()
    |> assign_recent_level_up_skill_classes()
    |> assign(:search, false)
  end

  defp apply_action(socket, :search, _params) do
    socket
    |> assign(:page_title, "スキル検索／スカウト")
    |> assign_skillset_gem()
    |> assign_recent_level_up_skill_classes()
    |> assign(:search, true)
  end

  defp apply_action(socket, :free_trial, params) do
    plan = Map.get(params, "plan", "hr_plan")

    socket
    |> assign(:page_title, "無料トライアル")
    |> assign_skillset_gem()
    |> assign_recent_level_up_skill_classes()
    |> assign(:plan, plan)
    |> assign(:search, false)
  end

  defp assign_skillset_gem(socket) do
    skillset_gem =
      SkillScores.get_skillset_gem(socket.assigns.display_user.id)
      |> Enum.sort_by(& &1.position, :asc)
      |> Enum.map(&[&1.name, floor(&1.percentage)])
      |> Enum.zip_reduce([], &(&2 ++ [&1]))
      |> then(fn
        [] -> nil
        [names, percentags] -> %{labels: names, data: percentags}
      end)

    assign(socket, :skillset_gem, skillset_gem)
  end

  defp assign_recent_level_up_skill_classes(socket) do
    %{display_user: display_user} = socket.assigns

    recent_level_up_skill_class_scores =
      SkillScores.list_recent_level_up_skill_class_scores(display_user)

    assign(socket, :recent_level_up_skill_class_scores, recent_level_up_skill_class_scores)
  end

  # local components
  # ---

  defp skill_ups(assigns) do
    ~H"""
    <section>
      <h5>スキルアップ</h5>
      <div class="bg-white rounded-md mt-1 px-2 py-0.5">
        <ul class="text-sm font-medium text-center gap-y-2">
          <li :for={skill_class_score <- @recent_level_up_skill_class_scores} class="flex flex-wrap my-2">
            <.link
              class="cursor-pointer hover:filter hover:brightness-[80%] text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap"
              href={skill_panel_path(skill_class_score, @display_user, @me, @anonymous)}
            >
              <img src="/images/common/icons/skill.svg" class="w-6 h-6 mr-2.5">
              <span class="order-3 lg:order-2 flex-1 mr-2">
                <%= skill_up_message(skill_class_score) %>
              </span>
            </.link>
          </li>
        </ul>
      </div>
    </section>
    """
  end

  defp skill_panel_path(skill_class_score, display_user, me, anonymous) do
    %{skill_class: %{class: class, skill_panel: skill_panel}} = skill_class_score

    PathHelper.skill_panel_path("graphs", skill_panel, display_user, me, anonymous) <>
      "?class=#{class}"
  end

  defp skill_up_message(skill_class_score) do
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
        "#{skill_panel_name}【#{skill_class_name}】が「#{level_name}」にレベルアップしました"
    end
  end
end
