defmodule Storybook.Components.Tab do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TabComponents.tab/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          tabs: ["tab1", "tab2", "tab3"],
          previous_enable: true
        },
        slots: [
          sample_slots()
        ]
      },
      %Variation{
        id: :selected_index_1,
        attributes: %{
          tabs: ["tab1", "tab2", "tab3"],
          selected_index: 1,
          next_enable: true,
          menu_enable: true
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
