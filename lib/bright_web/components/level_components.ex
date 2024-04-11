defmodule BrightWeb.LevelComponents do
  @moduledoc """
  Level Components
  """
  use Phoenix.Component

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
    IO.inspect(assigns)

    ~H"""
    <div class="flex justify-center">
      <p>
        あと<span class="text-error !text-2xl font-bold">8</span>%でベテランになれます。
      </p>
      <p>
        次のレベルまでのスキル数<span
          class="text-error !text-2xl font-bold"
          >10</span>個
      </p>
    </div>
    """
  end
end
