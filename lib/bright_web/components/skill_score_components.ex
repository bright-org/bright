defmodule BrightWeb.SkillScoreComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  @doc """
  Renders a Skill Gem

  ## Examples
      <.skill_gem data="[90, 80, 75, 60]" id="gem-single-skill4" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]} />
      <.skill_gem data={[[50, 50, 50, 80, 80, 80], [80, 80, 80, 50, 50, 50]]} id="gem-single-skill6-2-3" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]} />
  """
  attr :id, :string, required: true
  attr :data, :list, required: true
  attr :labels, :list, required: true

  def skill_gem(assigns) do
    assigns = assign(assigns, :labels, assigns.labels |> Jason.encode!())
    assigns = assign(assigns, :data, assigns.data |> Jason.encode!())

    ~H"""
    <div id={@id} phx-hook="SkillGem" phx-update="ignore" data-data={@data} data-labels={@labels}>
      <canvas></canvas>
    </div>
    """
  end

  @doc """
  Renders a Skill Set Gem

  ## Examples
      <.skill_set_gem data="[90, 80, 75, 60]" id="gem-single-skill4" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]} />
  """
  attr :id, :string, required: true
  attr :data, :list, required: true
  attr :labels, :list, required: true

  def skill_set_gem(assigns) do
    assigns = assign(assigns, :labels, assigns.labels |> Jason.encode!())
    assigns = assign(assigns, :data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="SkillGem"
      phx-update="ignore"
      data-data={@data}
      data-labels={@labels}
      data-type="skill-set"
    >
      <canvas></canvas>
    </div>
    """
  end
end
