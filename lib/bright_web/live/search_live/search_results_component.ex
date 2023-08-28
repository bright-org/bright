defmodule BrightWeb.SearchLive.SearchResultsComponent do
  use BrightWeb, :live_component

  alias Bright.{SkillPanels, Repo}

  def render(assigns) do
    ~H"""
    <ul class="mt-4">
      <%= for {user, index} <- Enum.with_index(@result) do %>
      <li class="border border-brightGray-200 min-h-64 max-h-72 mb-2 overflow-hidden p-2 rounded">
        <.live_component
          id={"user_search_result_#{index}"}
          module={BrightWeb.SearchLive.SearchResultComponent}
          user={user}
          index={index}
          skill_params={@skill_params}
        />
      </li>
      <% end %>
    </ul>
    """
  end

  def update(%{skill_params: skills} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:skill_params, put_skill_panel_name(skills))
    |> then(&{:ok, &1})
  end

  def put_skill_panel_name(skills) do
    Enum.map(skills, fn skill ->
      skill_panel =
        SkillPanels.get_skill_panel!(skill.skill_panel)
        |> Repo.preload(:skill_classes)

      Map.merge(skill, %{
        skill_panel_name: skill_panel.name,
        skill_class_id:
          Enum.find(skill_panel.skill_classes, fn class ->
            class.class == Map.get(skill, :class, 1)
          end).id
      })
    end)
  end
end
