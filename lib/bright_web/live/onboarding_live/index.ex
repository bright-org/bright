defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  @default_pos "engineer"

  @impl true
  def mount(_params, _session, socket) do
    scores = SkillPanels.list_skill_panels_with_score(socket.assigns.current_user.id)

    socket
    |> assign(:scores, scores)
    |> assign(:pos, @default_pos)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, uri, socket) do
    current_path = URI.parse(uri).path

    socket
    |> assign(:current_path, current_path)
    |> assign(:page_title, page_title(current_path))
    |> push_event("scroll-to", %{
      "id" => "#{Map.get(params, "career_field")}-#{Map.get(params, "job")}"
    })
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

  def handle_event("scroll_to", %{"pos" => pos}, socket) do
    socket
    |> push_event("scroll-to", %{"id" => pos})
    |> then(&{:noreply, &1})
  end

  def handle_event("position", %{"pos" => pos}, socket) do
    {:noreply, assign(socket, :pos, pos)}
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
