defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Listing Onboardings")}
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
end
