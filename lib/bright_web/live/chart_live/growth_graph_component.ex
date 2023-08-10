defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  alias Bright.SkillScores

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.growth_graph data={@data} id="growth-graph"/>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:data, create_data(assigns.user_id, assigns.skill_panel_id, assigns.class))

    {:ok, socket}
  end

  defp create_data(user_id, skill_panel_id, class) do
    now = SkillScores.get_class_score(user_id, skill_panel_id, class) |> get_now()

    %{
      labels: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
      # role: [10, 20, 50, 60, 75, 100],
      # myself: [nil, 0, 35, 45, 55, 65],
      myself: [nil, 0, 0, 0, 0, 0],
      # other: [10, 10, 25, 35, 45, 70],
      now: now,
      myselfSelected: "2023.6"
      # otherSelected: "2022.12"
    }
  end

  defp get_now(%{percentage: now}), do: now
  defp get_now(nil), do: 0
end
