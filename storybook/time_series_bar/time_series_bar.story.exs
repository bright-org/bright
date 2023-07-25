defmodule Storybook.Components.TimeSeriesBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TimeSeriesBarComponents.time_series_bar/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
