defmodule BrightWeb.BrightGraphComponents do
  @moduledoc """
  Graph
  """
  use Phoenix.Component

  @doc """
  Renders a TriangleGraph

  ## Examples

      <.TriangleGraph id="trianglegraph" />

  """
  attr :id, :string, required: true
  attr :data, :list, required: true

  def triangle_graph(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="TriangleGraph"
      hx-update="ignore"
      data-data={@data}
    >
      <canvas id="myCanvas1" width="300" height="200"></canvas>
      <canvas id="myCanvas2" width="300" height="200"></canvas>
      <canvas id="myCanvas3" width="300" height="200"></canvas>
    </div>
    """
  end
end
