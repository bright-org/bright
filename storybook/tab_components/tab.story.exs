defmodule Storybook.Components.Tab do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TabComponents.tab/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          tabs: ["tab1", "tab2"]
        },
        slots: [
          """
          <p class="text-base">タブの中身</p>
          """
        ]
      }
    ]
  end
end
