defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings

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
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("skip_onboarding", _value, socket) do
    current_user = socket.assigns.current_user

    onboarding = %{
      completed_at: NaiveDateTime.utc_now(),
      user_id: current_user.id
    }

    # TODO: user_onboardingは初回のみレコード登録する。スキルアップ画面対応のときはリンクを消す等検討する
    case Onboardings.create_user_onboarding(onboarding) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "オンボーディングをスキップしました")
         |> redirect(to: ~p"/mypage")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset)}
    end
  end

  @impl true
  def handle_event("toggle_panel", %{"panel" => panel}, socket) do
    IO.inspect(hide_panel(panel))

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
    IO.inspect(id)

    Map.keys(@panels)
    |> Enum.reject(&(&1 == id))
    |> List.first()
  end

  defp close(),
    do: "before:-mt-2 before:rotate-225"

  defp open(),
    do: "rounded-bl-none rounded-br-none before:-mt-0.5 before:rotate-45"
end
