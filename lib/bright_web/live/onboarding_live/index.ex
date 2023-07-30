defmodule BrightWeb.OnboardingLive.Index do
  use BrightWeb, :live_view

  embed_templates "index/*"

  alias Bright.Jobs
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
    list_career_wants_with_career_fields = Jobs.list_career_wants_with_career_fields()

    career_wants =
      list_career_wants_with_career_fields
      |> Enum.group_by(fn x -> x.career_want_id end)
      |> Enum.map(fn {_key, value} -> List.first(value) end)
      |> Enum.map(fn x -> %{id: x.career_want_id, name: x.career_want_name} end)

    list_career_fields =
      list_career_wants_with_career_fields
      |> Enum.group_by(fn x -> x.career_want_id end)
      |> Enum.map(fn {_key, value} ->
        Enum.map(value, fn x ->
          %{
            career_field_name: x.career_field_name,
            background_color: x.background_color,
            button_color: x.button_color
          }
        end)
      end)

    ~H"""
    <.select_career
      career_wants={career_wants}
      list_career_fields={list_career_fields}
    />
    """
  end
end
