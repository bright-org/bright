defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  @impl true
  def mount(_params, _session, socket) do
    scores = SkillPanels.list_skill_panels_with_score(socket.assigns.current_user.id)

    socket
    |> assign(:open_want_todo, false)
    |> assign(:open_wants_job, false)
    |> assign(:scores, scores)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(_, uri, socket) do
    current_path = URI.parse(uri).path

    socket
    |> assign(:current_path, current_path)
    |> assign(:page_title, page_title(current_path))
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("skip_onboarding", _value, %{assigns: %{current_user: user}} = socket) do
    skip_onboarding(user.user_onboardings, user.id)

    socket
    |> put_flash(:info, "オンボーディングをスキップしました")
    |> redirect(to: ~p"/teams/new")
    |> then(&{:noreply, &1})
  end

  def handle_event("request", _params, socket) do
    {:noreply, put_flash(socket, :info, "ジョブパネルのリクエストを受け付けました")}
  end

  defp skip_onboarding(nil, user_id) do
    {:ok, _onboarding} =
      Onboardings.create_user_onboarding(%{
        completed_at: NaiveDateTime.utc_now(),
        user_id: user_id
      })
  end

  defp skip_onboarding(%UserOnboarding{}, _), do: false

  defp page_title(<<"/onboardings", _rest::binary>>), do: "オンボーディング"
  defp page_title(<<"/more_skills", _rest::binary>>), do: "ジョブパネル"

  def hidden_more_skills(current_path) do
    if String.match?(current_path, ~r/onboarding/), do: "", else: "hidden"
  end
end
