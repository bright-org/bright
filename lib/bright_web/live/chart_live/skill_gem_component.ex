defmodule BrightWeb.ChartLive.SkillGemComponent do
  @moduledoc """
  Skill Gem Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  alias Bright.SkillScores
  alias Bright.HistoricalSkillUnitScore

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[450px] mx-auto my-12">
      <.skill_gem
        data={@skill_gem_data}
        id={@id}
        labels={@skill_gem_labels}/>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    select_label = assigns[:select_label] || "now"

    skill_gem =
      get_skill_gem(assigns.user_id, assigns.skill_panel_id, assigns.class, select_label)

    skill_gem_data = [skill_gem |> Enum.map(fn x -> x.percentage end)]
    skill_gem_labels = skill_gem |> Enum.map(fn x -> x.name end)

    socket =
      socket
      |> assign(:skill_gem_data, skill_gem_data)
      |> assign(:skill_gem_labels, skill_gem_labels)

    {:ok, socket}
  end

  def get_skill_gem(user_id, skill_panel_id, class, select_label) when select_label == "now",
    do: SkillScores.get_skill_gem(user_id, skill_panel_id, class)

  def get_skill_gem(user_id, skill_panel_id, class, select_label),
    do:
      HistoricalSkillUnitScore.get_historical_skill_gem(
        user_id,
        skill_panel_id,
        class,
        label_to_date(select_label)
      )

  defp label_to_date(date) do
    "#{date}.1"
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Date.from_erl!()
  end
end
