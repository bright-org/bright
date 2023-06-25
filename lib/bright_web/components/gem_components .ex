defmodule BrightWeb.GemComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.LiveComponent

  @doc """
  Renders a gem

  ## Examples
      <.gem />
  """
  attr :data, :any, required: true

  def gem(assigns) do
    ~H"""
    <div>
      <div id="gem" phx-hook="gem" phx-update="ignore" style="width:600px;height:400px" data-data={@data}>
        <canvas id="mychart"></canvas>
      </div>
    </div>
    """
  end
end
