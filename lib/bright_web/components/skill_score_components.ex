defmodule BrightWeb.SkillScoreComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  @doc """
  Renders a Skill Gem

  ## Examples
      <.skill_gem data="[90, 80, 75, 60]" id="gem-single-skill4" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]} size="sm" />
      <.skill_gem data={[[50, 50, 50, 80, 80, 80], [80, 80, 80, 50, 50, 50]]} id="gem-single-skill6-2-3" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]} />
  """
  attr :id, :string, required: true
  attr :data, :list, required: true
  attr :labels, :list, required: true
  attr :size, :string, default: "base", values: ["sm", "base"]
  attr :display_link, :string, default: "true", values: ["true", "false"]
  attr :color_thema, :string, default: "other", values: ["myself", "other"]

  def skill_gem(assigns) do
    assigns =
      assigns
      |> assign(:labels, assigns.labels |> Jason.encode!())
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="SkillGem"
      phx-update="ignore"
      data-data={@data}
      data-labels={@labels}
      data-size={@size}
      data-display-link={@display_link}
      data-color-thema={@color_thema}
    >
      <canvas></canvas>
    </div>
    """
  end
end
