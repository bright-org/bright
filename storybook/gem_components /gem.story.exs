defmodule Storybook.GemComponents.Gem do
  use PhoenixStorybook.Story, :component

  @spec function :: (any -> any)
  def function, do: &Elixir.BrightWeb.GemComponents.gem/1

  def variations do
    [
      %Variation{
        id: :skillgem,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45]"
        },
      }
    ]
  end
end
