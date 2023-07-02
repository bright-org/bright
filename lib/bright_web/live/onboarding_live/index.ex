defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view
  import BrightWeb.OnbordingComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def render(assigns) do
    case assigns[:view_content] do
      :select_skill_panel ->
        ~H"""
        <.select_skill_panel />
        """

      _ ->
        ~H"""
        <.select_career />
        """
    end
  end

  defp apply_action(socket, :index, params) do
    onboarding = params["onboarding"]

    view_content =
      cond do
        onboarding == "select_skill_panel" ->
          :select_skill_panel

        true ->
          :select_career
      end

    socket
    |> assign(:page_title, "Listing Onboardings")
    |> assign(:view_content, view_content)
  end
end
