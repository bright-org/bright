defmodule BrightWeb.Admin.UserOnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :user_onboardings, list_user_onboardings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User onboarding")
    |> assign(:user_onboarding, Onboardings.get_user_onboarding!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User onboarding")
    |> assign(:user_onboarding, %UserOnboarding{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing User onboardings")
    |> assign(:user_onboarding, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.UserOnboardingLive.FormComponent, {:saved, user_onboarding}},
        socket
      ) do
    {:noreply, stream_insert(socket, :user_onboardings, user_onboarding, at: 0)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_onboarding = Onboardings.get_user_onboarding!(id)
    {:ok, _} = Onboardings.delete_user_onboarding(user_onboarding)

    {:noreply, stream_delete(socket, :user_onboardings, user_onboarding)}
  end

  defp list_user_onboardings do
    Onboardings.list_user_onboardings()
    |> Enum.sort_by(& &1.updated_at, {:desc, NaiveDateTime})
  end
end
