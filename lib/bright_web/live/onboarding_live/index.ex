defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view
  import BrightWeb.OnboardingComponents

  embed_templates "index/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Onboardings")
    |> assign(:view_content, view_content(params["onboarding"]))
  end

  defp view_content("select_skill_panel"), do: :select_skill_panel
  defp view_content("select_skill_result"), do: :select_skill_result
  defp view_content(_), do: :select_career

  @impl true
  def render(assigns) do
    case assigns[:view_content] do
      :select_skill_panel ->
        ~H"""
        <.select_skill_panel />
        """

      :select_skill_result ->
        ~H"""
        <.select_skill_result />
        """

      _ ->
        ~H"""
        <.select_career />
        """
    end
  end
end
