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

    ~H"""
    <div class="flex justify-center">
      <.level_render
       level={@level}
       next_percentage={@next_percentage}
      />
    </div>
    """
  end

  defp level_render(%{level: :beginner} = assigns) do
    ~H"""
    <p>
    あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%で平均になれます。
    </p>
    <p>
      次のレベルまでのスキル数<span
        class="text-error !text-2xl font-bold"
        >10</span>個
    </p>
    """
  end

  defp level_render(%{level: :normal} = assigns) do
    ~H"""
    <p>
    あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%でベテランになれます。
    </p>
    <p>
      次のレベルまでのスキル数<span
        class="text-error !text-2xl font-bold"
        >10</span>個
    </p>
    """
  end

  defp level_render(%{level: :skilled} = assigns) do
    ~H"""
    <p>
    あと<span class="text-error !text-2xl font-bold"><%= @next_percentage %></span>%でマスターになれます。
    </p>
    <p>
      マスターまでのスキル数<span
        class="text-error !text-2xl font-bold"
        >10</span>個
    </p>
    """
  end

  defp level_render(%{level: :master} = assigns) do
    ~H"""
    <p>
     このスキルはマスターしました。
    </p>
    <p>
     おめでとうございます
    </p>
    """
  end

  defp get_next_percentage(:beginner, percentage), do: @normal_level - percentage
  defp get_next_percentage(:normal, percentage), do: @skilled_level - percentage
  defp get_next_percentage(:skilled, percentage), do: @master_level - percentage
  defp get_next_percentage(:master, _percentage), do: 0

  defp get_level(100), do: :master
  defp get_level(percentage), do: SkillScores.get_level(percentage)
end
