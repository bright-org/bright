defmodule BrightWeb.SkillUpLive.Index do
  use BrightWeb, :live_view


  @panels %{
    "want_todo_panel" => :open_want_todo,
    "wants_job_panel" => :open_wants_job
  }

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "スキルアップ")
    |> assign(:open_want_todo, false)
    |> assign(:open_wants_job, false)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("toggle_panel", %{"panel" => panel}, socket) do
    socket
    |> assign(@panels[panel], !Map.get(socket.assigns, @panels[panel]))
    |> assign(@panels[hide_panel(panel)], false)
    |> then(&{:noreply, &1})
  end

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
