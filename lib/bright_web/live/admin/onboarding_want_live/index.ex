defmodule BrightWeb.Admin.OnboardingWantLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings
  alias Bright.Onboardings.OnboardingWant

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :onboarding_wants, Onboardings.list_onboarding_wants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Onboarding want")
    |> assign(:onboarding_want, Onboardings.get_onboarding_want!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Onboarding want")
    |> assign(:onboarding_want, %OnboardingWant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Onboarding wants")
    |> assign(:onboarding_want, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.OnboardingWantLive.FormComponent, {:saved, onboarding_want}},
        socket
      ) do
    {:noreply, stream_insert(socket, :onboarding_wants, onboarding_want)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    onboarding_want = Onboardings.get_onboarding_want!(id)
    {:ok, _} = Onboardings.delete_onboarding_want(onboarding_want)

    {:noreply, stream_delete(socket, :onboarding_wants, onboarding_want)}
  end
end
