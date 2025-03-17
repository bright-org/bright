defmodule BrightWeb.BrightGraphComponents do
  @moduledoc """
  Graph
  """
  use BrightWeb, :component

  @doc """
  Renders a TriangleGraph

  ## Examples

      <.triangle_graph data={%{normal: 35, beginner: 35, skilled: 30}} id="triangle-graph-single-default"/>

  """
  attr :id, :string, required: true
  attr :data, :map, required: true

  def triangle_graph(assigns) do
    assigns =
      assigns
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="TriangleGraph"
      phx-update="ignore"
      data-data={@data}
      data-label={%{beginner: gettext("level_beginner"), normal: gettext("level_normal"), skilled: gettext("level_skilled")} |> Jason.encode!()}
    >
      <canvas width="350" height="130"></canvas>
    </div>
    """
  end
end
