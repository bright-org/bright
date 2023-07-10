defmodule Storybook.Components.Tab do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TabComponents.tab/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          tabs: ["tab1", "tab2", "tab3"]
        },
        slots: [
          sample_slots()
        ]
      }
    ]
  end

  defp sample_slots do
    """
    <p class="text-base">タブの中身１２３４５６７８９１２３４５６７８９０</p><br>
    <p class="text-base">タブの中身１２３４５６７８９１２３４５６７８９０</p><br>
    <p class="text-base">タブの中身１２３４５６７８９１２３４５６７８９０</p><br>
    """
  end
end
