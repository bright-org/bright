defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  embed_templates "index/*"

  alias Bright.Onboardings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("skip_onboarding", _value, socket) do
    current_user = socket.assigns.current_user

    onboarding = %{
      completed_at: NaiveDateTime.utc_now(),
      user_id: current_user.id
    }

    {:ok, _} = Onboardings.create_user_onboarding(onboarding)

    {:noreply,
     socket
     |> put_flash(:info, "オンボーディングをスキップしました")
     |> redirect(to: ~p"/mypage")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Onboardings")
    |> assign(:view_content, params["onboarding"])
  end

  @impl true
  def render(%{view_content: "select_skill_panel"} = assigns) do
    ~H"""
    <.select_skill_panel />
    """
  end

  def render(%{view_content: "select_skill_result"} = assigns) do
    ~H"""
    <.select_skill_result />
    """
  end

  def render(%{view_content: _} = assigns) do
    ~H"""
    <.select_career datas={Onboardings.list_onboarding_wants()} />
    """
  end
end
