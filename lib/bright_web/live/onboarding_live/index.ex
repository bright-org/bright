defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  @panels %{
    "want_todo_panel" => :open_want_todo,
    "wants_job_panel" => :open_wants_job
  }

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "オンボーディング")
    |> assign(:open_want_todo, false)
    |> assign(:open_wants_job, false)
    |> assign(:tab, "engineer")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(%{"open" => panel, "tab" => tab}, _uri, socket) do
    socket
    |> assign(:open, panel)
    |> assign(:tab, tab)
    |> then(&{:noreply, &1})
  end

  def handle_params(%{"open" => panel}, _uri, socket) do
    socket
    |> assign(:open, panel)
    |> then(&{:noreply, &1})
  end

  def handle_params(_, _uri, socket), do: {:noreply, assign(socket, open: false)}

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
end
