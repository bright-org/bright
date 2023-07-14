defmodule BrightWeb.Admin.OnboardingWantLive.Show do
  use BrightWeb, :live_view

  alias Bright.Onboardings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:onboarding_want, Onboardings.get_onboarding_want!(id))}
  end

  defp page_title(:show), do: "Show Onboarding want"
  defp page_title(:edit), do: "Edit Onboarding want"
end
