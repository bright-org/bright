defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  @default_tab "engineer"
  @panels %{
    "want_todo_panel" => :open_want_todo,
    "wants_job_panel" => :open_wants_job
  }

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:open_want_todo, false)
    |> assign(:open_wants_job, false)
    |> assign(:tab, @default_tab)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, uri, socket) do
    current_path = URI.parse(uri).path |> IO.inspect()

    socket
    |> assign(:current_path, current_path)
    |> assign(:page_title, page_title(current_path))
    |> assign_params(params)
    |> then(&{:noreply, &1})
  end

  defp assign_params(socket, params) do
    socket
    |> assign(:open, Map.get(params, "open", false))
    |> assign(:tab, Map.get(params, "tab", "engineer"))
  end

  @impl true
  def handle_event("skip_onboarding", _value, %{assigns: %{current_user: user}} = socket) do
    skip_onboarding(user.user_onboardings, user.id)

    socket
    |> put_flash(:info, "オンボーディングをスキップしました")
    |> redirect(to: ~p"/mypage")
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("toggle_panel", %{"panel" => panel}, socket) do
    socket
    |> assign(@panels[panel], !Map.get(socket.assigns, @panels[panel]))
    |> assign(@panels[hide_panel(panel)], false)
    |> then(&{:noreply, &1})
  end

  defp skip_onboarding(nil, user_id) do
    {:ok, _onboarding} =
      Onboardings.create_user_onboarding(%{
        completed_at: NaiveDateTime.utc_now(),
        user_id: user_id
      })
  end

  defp skip_onboarding(%UserOnboarding{}, _), do: false

  defp toggle(js \\ %JS{}, id) do
    js
    |> JS.push("toggle_panel", value: %{panel: id})
    |> JS.toggle(to: "##{id}")
    |> JS.hide(to: "##{hide_panel(id)}")
  end

  defp hide_panel(id) do
    Map.keys(@panels)
    |> Enum.reject(&(&1 == id))
    |> List.first()
  end

  defp close(),
    do: "before:-mt-2 before:rotate-225"

  defp open(),
    do: "rounded-bl-none rounded-br-none before:-mt-0.5 before:rotate-45"

  defp page_title("/onbaordings"), do: "オンボーディング"
  defp page_title("/skill_up"), do: "スキルアップ"
end
