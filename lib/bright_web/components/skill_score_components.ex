defmodule BrightWeb.SkillScoreComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  @doc """
  Renders a Skill Gem

  ## Examples
      <.skill_gem data="[90, 80, 75, 60]" id="gem-single-skill4" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]} data2="[]"/>
      <.skill_gem data="[50, 50, 50, 80, 80, 80]" id="gem-single-skill6-2-3" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]} data2="[80, 80, 80, 50, 50, 50]"/>
  """
  attr :id, :string, required: true
  attr :data, :string, required: true
  attr :data2, :string, required: true
  attr :labels, :any, required: true

  def skill_gem(assigns) do
    assigns = assign(assigns, :labels, assigns.labels |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="skill_gem"
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
