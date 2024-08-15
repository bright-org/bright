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

  def triangle_graph(assigns) do
    ~H"""
    <div>
    test
    </div>
    """
  end
end
