defmodule BrightWeb.SearchLive.SearchResultsComponent do
  use BrightWeb, :live_component

  alias Bright.Repo
  alias Bright.SkillPanels
  alias Bright.Teams
  alias Bright.Accounts

  def render(assigns) do
    ~H"""
    <ul class="mt-4">
      <%= for {user, index} <- Enum.with_index(@result) do %>
        <li>
          <.live_component
            id={"#{@prefix}_search_result_#{index}"}
            search={@search}
            prefix={@prefix}
            module={BrightWeb.SearchLive.SearchResultComponent}
            anon={!Enum.member?(@team_members, user.id)}
            user={user}
            index={index}
            skill_params={@skill_params}
            stock_user_ids={@stock_user_ids}
            hr_enabled={@hr_enabled}
          />
        </li>
      <% end %>
    </ul>
    """
  end

  def update(%{skill_params: skill_params, current_user: user} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:hr_enabled, Accounts.hr_enabled?(user.id))
    |> assign(:skill_params, put_skill_panel_name(skill_params))
    |> assign(:team_members, Teams.list_user_ids_related_team_by_user(user))
    |> then(&{:ok, &1})
  end

  def update(%{hr_enabled: true}, socket), do: {:ok, assign(socket, :hr_enabled, true)}

  def put_skill_panel_name(skill_params) do
    Enum.map(skill_params, fn params ->
      skill_panel =
        SkillPanels.get_skill_panel!(params.skill_panel)
        |> Repo.preload(:skill_classes)

      Map.merge(params, %{
        skill_panel_name: String.slice(skill_panel.name, 0..19),
        class: Map.get(params, :class, 1),
        skill_class_id:
          Enum.find(skill_panel.skill_classes, fn class ->
            class.class == Map.get(params, :class, 1)
          end).id
      })
    end)
  end
end
