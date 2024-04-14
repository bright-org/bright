defmodule BrightWeb.NextLevelAnnounceComponents do
  @moduledoc """
  Level Components
  """
  use Phoenix.Component
  alias Bright.SkillScores

  @next_level %{beginner: "平均", normal: "ベテラン", skilled: "マスター"}

  @doc """
  Renders a Level
  ## Examples
       <.next_level_announce
          value={@counter.high}
          size={@num_skills}
        />
  """

  attr :value, :integer
  attr :size, :integer

  def next_level_announce(assigns) do
    percentage = SkillScores.calc_high_skills_percentage(assigns.value, assigns.size)
    level = get_level(percentage)

    assigns =
      assigns
      |> assign(level: level)
      |> assign(next_percentage: get_next_percentage(level, percentage))
      |> assign(next_num_skills: get_next_num_skills(level, assigns.size, assigns.value))

    ~H"""
    <div class="flex px-10">
      <.level_render
       level={@level}
       next_percentage={@next_percentage}
       next_num_skills={@next_num_skills}
      />
    </div>
    """
  end

  defp level_render(%{level: :master} = assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div>
        このスキルはマスターしました。
      </div>
      <div>
        おめでとうございます
      </div>
    </div>
    """
  end

  defp level_render(assigns) do
    assigns = assign(assigns, next_level_name: Map.get(@next_level, assigns.level))

    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div>
        あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%で<%= @next_level_name %>になれます。
      </div>
      <div>
        <%= @next_level_name %>までのスキル数<span class="text-error !text-2xl font-bold" ><%= @next_num_skills %></span>個
      </div>
    </div>
    """
  end

  defp get_next_percentage(:beginner, percentage),
    do: SkillScores.get_level_judgment_value(:normal) - percentage

  defp get_next_percentage(:normal, percentage),
    do: SkillScores.get_level_judgment_value(:skilled) - percentage

  defp get_next_percentage(:skilled, percentage),
    do: SkillScores.get_level_judgment_value(:master) - percentage

  defp get_next_percentage(:master, _percentage), do: 0

  defp get_next_num_skills(:beginner, num_skills, current_skills),
    do: ceil(num_skills * (SkillScores.get_level_judgment_value(:normal) / 100) - current_skills)

  defp get_next_num_skills(:normal, num_skills, current_skills),
    do: ceil(num_skills * (SkillScores.get_level_judgment_value(:skilled) / 100) - current_skills)

  defp get_next_num_skills(:skilled, num_skills, current_skills),
    do: ceil(num_skills - current_skills)

  defp get_next_num_skills(:master, _num_skills, _current_skills), do: 0

  defp get_level(100), do: :master
  defp get_level(percentage), do: SkillScores.get_level(percentage)
end
