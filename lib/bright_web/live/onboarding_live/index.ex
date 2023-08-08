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
    |> assign(:view_content, params["step"])
    |> assign(:id, params["id"])
  end

  @impl true
  def render(%{view_content: "select_skill_panel"} = assigns) do
    # skill_panels = Job.list_skill_panels_by_career_want_id(assigns[:id])
    skill_panels = Jobs.list_skill_panels_by_career_want_id()
    career_fields = Jobs.list_career_fields_by_career_wants()

    assigns =
      assign(assigns,
        skill_panels_by_career_fields: skill_panels,
        career_fields: career_fields
      )

    ~H"""
    <.select_skill_panel
      skill_panels_by_career_fields={@skill_panels_by_career_fields}
      career_fields={@career_fields}
    />
    """
  end

  def render(%{view_content: "select_skill_result"} = assigns) do
    skill_units = ["Elixir本体", "Elixirフレームワーク／ライブラリ", "Elixirテスト", "設計・管理"]

    assigns =
      assign(assigns,
        skill_units: skill_units
      )

    ~H"""
    <.select_skill_result
      career_field_name_en="engineer"
      skill_units={@skill_units}
    />
    """
  end

  def render(%{view_content: _} = assigns) do
    career_wants = Jobs.list_career_want_jobs_with_career_wants()
    career_fields_wants = Jobs.list_career_wants_jobs_with_career_fields()
    career_fields = Jobs.list_career_fields()

    assigns =
      assign(assigns,
        career_wants: career_wants,
        career_fields_wants: career_fields_wants,
        career_fields: career_fields
      )

    ~H"""
    <.select_career
      career_wants={@career_wants}
      career_fields_wants={@career_fields_wants}
      career_fields={@career_fields}
    />
    """
  end
end
