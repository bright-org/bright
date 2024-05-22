defmodule BrightWeb.NextLevelAnnounceComponents do
  @moduledoc """
  Level Components
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  alias Bright.SkillScores

  @next_level_jp %{beginner: "平均", normal: "ベテラン", skilled: "マスター"}
  @next_level %{beginner: :normal, normal: :skilled, skilled: :master}

  @doc """
  Renders a Next Level Announce
  ## Examples
       <.next_level_announce
          value={@counter.high}
          size={@num_skills}
          skill_panel_id={@skill_panel_id}
        />
  """

  attr :value, :integer
  attr :size, :integer
  attr :skill_panel_id, :string

  def next_level_announce(assigns) do
    percentage = SkillScores.calc_high_skills_percentage(assigns.value, assigns.size)
    level = get_level(percentage)

    assigns =
      assigns
      |> assign(level: level)
      |> assign(next_percentage: get_next_percentage(level, percentage))
      |> assign(next_num_skills: get_next_num_skills(level, assigns.size, assigns.value))

    ~H"""
    <div class="flex pb-4">
      <.level_render
       level={@level}
       next_percentage={@next_percentage}
       next_num_skills={@next_num_skills}
       skill_panel_id={@skill_panel_id}
      />
    </div>
    """
  end

  defp level_render(%{level: :master} = assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div class="leading-8">
        このスキルはマスターしました。
      </div>
      <div class="leading-8">
        おめでとうございます
      </div>
      <div class="px-2 leading-8">
        <.remuneration_consultation_button skill_panel_id={@skill_panel_id}/>
      </div>
    </div>
    """
  end

  defp level_render(assigns) do
    assigns = assign(assigns, next_level_name: Map.get(@next_level_jp, assigns.level))

    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div>
        あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%で<%= @next_level_name %>になれます。
      </div>
      <div>
        <%= @next_level_name %>までのスキル数<span class="text-error !text-2xl font-bold" ><%= @next_num_skills %></span>個
      </div>
      <div class="px-2">
        <.remuneration_consultation_button skill_panel_id={@skill_panel_id}/>
      </div>
    </div>
    """
  end

  defp get_next_percentage(:master, _percentage), do: 0

  defp get_next_percentage(level, percentage),
    do: SkillScores.get_level_judgment_value(Map.get(@next_level, level)) - percentage

  defp get_next_num_skills(:master, _num_skills, _current_skills), do: 0

  defp get_next_num_skills(level, num_skills, current_skills),
    do:
      ceil(
        num_skills * (SkillScores.get_level_judgment_value(Map.get(@next_level, level)) / 100) -
          current_skills
      )

  defp get_level(100), do: :master
  defp get_level(percentage), do: SkillScores.get_level(percentage)
end
