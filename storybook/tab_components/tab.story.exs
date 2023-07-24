defmodule Storybook.Components.Tab do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TabComponents.tab/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          tabs: [
            {"tab1", "タブ1"},
            {"tab2", "タブ2"},
            {"tab3", "タブ3"}
          ],
          selected_tab: "tab1",
          page: 1,
          total_pages: 2
        },
        slots: [
          sample_slots()
        ]
      },
      %Variation{
        id: :selected_index_1,
        attributes: %{
          tabs: [
            {"tab1", "タブ1"},
            {"tab2", "タブ2"},
            {"tab3", "タブ3"}
          ],
          selected_tab: "tab2",
          page: 2,
          total_pages: 2,
          menu_items: [
            %{text: "test", href: "/storybook"},
            %{text: "test2", href: "/storybook/core_components/button"}
          ]
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
