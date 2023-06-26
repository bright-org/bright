defmodule BrightWeb.GemComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  @doc """
  Renders a gem

  ## Examples
      <.gem />
  """
  attr :id, :string, required: true
  attr :data, :string, required: true
  attr :data2, :string, required: true
  attr :labels, :any, required: true

  def gem(assigns) do
    assigns = assign(assigns, :labels, assigns.labels |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="gem"
      phx-update="ignore"
      style="width:600px;height:400px"
      data-data={@data}
      data-data2={@data2}
      data-labels={@labels}
    >
      <canvas></canvas>
    </div>
    """
  end
end
