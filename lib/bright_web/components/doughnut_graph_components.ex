defmodule BrightWeb.DoughnutGraphComponents do
  @moduledoc """
  doughnut Graph Components
  """

  use Phoenix.Component

  @doc """
  Renders a Doughnut Graph

  ## Examples

      <.doughnut_graph data="[90, 80, 75, 60]" id="doughnut" />

  """
  attr :id, :string, required: true
  attr :data, :list, required: true

  def doughnut_graph(assigns) do
    assigns =
      assigns
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="DoughnutGraph"
      phx-update="ignore"
      data-data={@data}
    >
      <canvas></canvas>
    </div>
    """
  end
end
