defmodule BrightWeb.LevelComponents do
  @moduledoc """
  Level Components
  """
  use Phoenix.Component
  alias Bright.SkillScores

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
    IO.inspect("--------------")
    # IO.inspect(assigns)
    SkillScores.calc_high_skills_percentage(assigns.value, assigns.size)
    |> IO.inspect()
    |> get_level()
    |> IO.inspect()

    ~H"""
    <div class="flex justify-center">
      <.level_render />
    </div>
    """
  end

  defp level_render(assigns) do
    ~H"""
    <p>
    あと<span class="text-error !text-2xl font-bold">8</span>%でベテランになれます。
    </p>
    <p>
      次のレベルまでのスキル数<span
        class="text-error !text-2xl font-bold"
        >10</span>個
    </p>
    """
  end

  defp get_level(100), do: :master
  defp get_level(percentage), do: SkillScores.get_level(percentage)
end
