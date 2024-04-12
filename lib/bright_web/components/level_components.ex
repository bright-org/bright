defmodule BrightWeb.LevelComponents do
  @moduledoc """
  Level Components
  """
  use Phoenix.Component
  alias Bright.SkillScores

  # レベルの判定値
  @normal_level 40
  @skilled_level 60
  @master_level 100

  @doc """
  Renders a Level
  ## Examples
       <.level
          value={@counter.high}
          size={@num_skills}
        />
  """

  attr :value, :integer
  attr :size, :integer

  def level(assigns) do
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

  defp level_render(%{level: :beginner} = assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
     <div>
      あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%で平均になれます。
     </div>
     <div>
      次のレベルまでのスキル数<span class="text-error !text-2xl font-bold" ><%= @next_num_skills %></span>個
      </div>
    </div>
    """
  end

  defp level_render(%{level: :normal} = assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div>
        あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%でベテランになれます。
      </div>
      <div>
        次のレベルまでのスキル数<span class="text-error !text-2xl font-bold"><%= @next_num_skills %></span>個
      </div>
    </div>
    """
  end

  defp level_render(%{level: :skilled} = assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div>
        あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%でマスターになれます。
      </div>
      <div>
        マスターまでのスキル数<span class="text-error !text-2xl font-bold"><%= @next_num_skills %></span>個
      </div>
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

  defp get_next_percentage(:beginner, percentage), do: @normal_level - percentage
  defp get_next_percentage(:normal, percentage), do: @skilled_level - percentage
  defp get_next_percentage(:skilled, percentage), do: @master_level - percentage
  defp get_next_percentage(:master, _percentage), do: 0

  defp get_next_num_skills(:beginner, num_skills, current_skills),
    do: ceil(num_skills * (@normal_level / 100) - current_skills)

  defp get_next_num_skills(:normal, num_skills, current_skills),
    do: ceil(num_skills * (@skilled_level / 100) - current_skills)

  defp get_next_num_skills(:skilled, num_skills, current_skills),
    do: ceil(num_skills - current_skills)

  defp get_next_num_skills(:master, _num_skills, _current_skills), do: 0

  defp get_level(100), do: :master
  defp get_level(percentage), do: SkillScores.get_level(percentage)
end
