defmodule BrightWeb.ChartLive.SkillGemComponent do
  @moduledoc """
  Skill Gem Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  alias Bright.SkillScores
  alias Bright.HistoricalSkillUnitScore
  alias BrightWeb.PathHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[450px] mx-auto my-12">
      <.skill_gem
        data={@skill_gem_data}
        id={@id}
        labels={@skill_gem_labels}
        links={@skill_gem_links}
      />
    </div>
    """
  end

  @impl true
  def update(
        %{
          display_user: display_user,
          skill_panel: skill_panel,
          class: class,
          me: me,
          anonymous: anonymous
        } = assigns,
        socket
      ) do
    socket =
      socket
      |> assign(assigns)

    select_label = assigns[:select_label] || "now"
    skill_gem = get_skill_gem(display_user.id, skill_panel.id, class, select_label)

    socket =
      socket
      |> assign(:skill_gem_data, get_skill_gem_data(skill_gem))
      |> assign(:skill_gem_labels, get_skill_gem_labels(skill_gem))
      |> assign(
        :skill_gem_links,
        get_skill_gem_links(skill_gem, skill_panel, class, display_user, me, anonymous)
      )

    {:ok, socket}
  end

  def get_skill_gem(user_id, skill_panel_id, class, select_label) when select_label == "now",
    do: SkillScores.get_skill_gem(user_id, skill_panel_id, class)

  def get_skill_gem(user_id, skill_panel_id, class, select_label) do
    skill_gem =
      HistoricalSkillUnitScore.get_historical_skill_gem(
        user_id,
        skill_panel_id,
        class,
        label_to_date(select_label)
      )

    if skill_gem == [] do
      get_skill_gem(user_id, skill_panel_id, class, "now")
      |> Enum.map(fn x -> Map.put(x, :percentage, 0) end)
    else
      skill_gem
    end
  end

  defp label_to_date(date) do
    "#{date}.1"
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Date.from_erl!()
  end

  defp get_skill_gem_data(skill_gem), do: [skill_gem |> Enum.map(fn x -> x.percentage end)]
  defp get_skill_gem_labels(skill_gem), do: skill_gem |> Enum.map(fn x -> x.name end)

  defp get_skill_gem_links(skill_gem, skill_panel, class, display_user, me, anonymous) do
    base_path =
      PathHelper.skill_panel_path("panels", skill_panel, display_user, me, anonymous) <>
        "?class=#{class}"

    skill_gem
    |> Enum.map(fn x -> "#{base_path}#unit-#{x.position}" end)
  end
end
