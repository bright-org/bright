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
    # SkillScores.calc_high_skills_percentage(assigns.value, assigns.size)
    # |> IO.inspect()
    # |> get_level()
    # |> IO.inspect()

    assigns =
      assigns
      |> assign(
        level: SkillScores.calc_high_skills_percentage(assigns.value, assigns.size) |> get_level()
      )

    ~H"""
    <div class="flex justify-center">
      <.level_render
       level={@level}
      />
    </div>
    """
  end

  defp level_render(%{level: :beginner} = assigns) do
    IO.inspect(assigns)

    ~H"""
    <p>
    あと<span class="text-error !text-2xl font-bold">8</span>%で平均になれます。
    </p>
    <p>
      次のレベルまでのスキル数<span
        class="text-error !text-2xl font-bold"
        >10</span>個
    </p>
    """
  end

  defp level_render(%{level: :normal} = assigns) do
    IO.inspect(assigns)

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

  defp level_render(%{level: :skilled} = assigns) do
    IO.inspect(assigns)

    ~H"""
    <p>
    あと<span class="text-error !text-2xl font-bold">8</span>%でマスターになれます。
    </p>
    <p>
      マスターまでのスキル数<span
        class="text-error !text-2xl font-bold"
        >10</span>個
    </p>
    """
  end

  defp level_render(%{level: :master} = assigns) do
    IO.inspect(assigns)

    ~H"""
    <p>
     このスキルはマスターしました。
    </p>
    <p>
     おめでとうございます
    </p>
    """
  end

  defp get_level(100), do: :master
  defp get_level(percentage), do: SkillScores.get_level(percentage)
end
