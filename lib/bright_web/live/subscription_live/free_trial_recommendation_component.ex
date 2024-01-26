defmodule BrightWeb.SubscriptionLive.FreeTrialRecommendationComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions
  alias Bright.Subscriptions.FreeTrialForm, as: FreeTrial
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.BrightButtonComponents, only: [plan_upgrade_button: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <main
        id={@id}
        class={"flex h-screen items-center justify-center p-10 w-screen #{if !@open, do: "hidden"}"}
        :if={@plan}
      >
        <div class="bg-pureGray-600/90 fixed inset-0 transition-opacity z-[55]" />
        <section
          class="absolute bg-white h-[700px] left-1/2 -ml-[340px] -mt-[230px] px-10 py-8 shadow text-sm top-1/2 w-[680px] z-[60]"
          phx-click-away="close"
          phx-target={@myself}
        >
          <h2 class="font-bold text-3xl">
            <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
              β期間終了までお試しいただけます
            </span>
          </h2>
          <p class="mt-2">
            ※現在、面談調整とチャットまでお試しいただけます
          </p>
          <p class="mt-2">
            (お試し期間以降もご利用される場合はプランのアップグレードが必要です)
          </p>
          <div class="mt-8">
            <h3 class="font-bold text-xl">
              <%= @plan.name_jp %>プラン
            </h3>
            <p class="mt-2">
              お試しいただくには、下記を入力し「開始する」ボタンをクリックしてください
            </p>

            <div class="pt-4">
              <.form
                for={@form}
                id="free_trial_recommendation_form"
                phx-target={@myself}
                phx-change="validate"
                phx-submit="submit"
              >

                <label class="flex items-center py-2">
                  <span class="font-bold w-52">会社名</span>
                  <BrightCore.input
                    field={@form[:company_name]}
                    input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
                    size="20"
                    type="text"
                  />
                </label>

                <label class="flex items-center py-2">
                  <span class="font-bold w-52">連絡先（電話番号）</span>
                  <BrightCore.input
                    field={@form[:phone_number]}
                    input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
                    size="20"
                    type="text"
                  />
                </label>

                <label class="flex items-center py-2">
                  <span class="font-bold w-52">連絡先（メールアドレス）</span>
                  <BrightCore.input
                    field={@form[:email]}
                    input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
                    size="20"
                    type="text"
                  />
                </label>

                <label class="flex items-center py-2">
                  <span class="font-bold w-52">担当者（本名）</span>
                  <BrightCore.input
                    field={@form[:pic_name]}
                    input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
                    size="20"
                    type="text"
                  />
                </label>

                <div class="flex justify-center gap-x-4 mt-8">
                  <button
                    class="text-sm font-bold py-3 rounded text-white bg-brightGray-900 border border-brightGray-900 w-72"
                  >
                    開始する
                  </button>
                </div>
              </.form>
              <div class="my-4">
                <p class="my-4">
                  下記「プランのアップグレード」ボタンよりアップグレードできます（別タブで開きます）
                </p>
                <div class="flex justify-center">
                <.plan_upgrade_button />
                </div>
              </div>
            </div>

            <!-- close button -->
            <button class="absolute right-5 top-5 z-10">
              <span
                class="material-icons !text-3xl text-brightGray-900"
                phx-click="close"
                phx-target={@myself}
              >
                close</span>
            </button>
          </div>
        </section>
      </main>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:plan, nil)
     |> assign(on_submit: nil, on_close: nil)}
  end

  @impl true
  def update(%{open: true, service_code: require_service_code} = assigns, socket) do
    # モーダルを開く
    # どの無料トライアルプランによりservice_codeを満たすかを決定する
    # TODO: plan取得とfree_trial可能かどうかは別途判定が必要
    user = socket.assigns.current_user
    plan = get_plan_by_service(user, require_service_code)

    {:ok, assign_on_open(socket, plan, assigns)}
  end

  def update(%{open: true, create_teams_limit: require_create_teams_limit} = assigns, socket) do
    # モーダルを開く
    # どの無料トライアルプランにより指定上限数を満たすかを決定する
    # TODO: plan取得とfree_trial可能かどうかは別途判定が必要
    user = socket.assigns.current_user
    plan = get_plan_by_create_teams_limit(user, require_create_teams_limit)

    {:ok, assign_on_open(socket, plan, assigns)}
  end

  def update(%{open: true, team_members_limit: require_team_members_limit} = assigns, socket) do
    # モーダルを開く
    # どの無料トライアルプランにより指定上限数を満たすかを決定する
    # TODO: plan取得とfree_trial可能かどうかは別途判定が必要
    user = socket.assigns.current_user
    plan = get_plan_by_team_members_limit(user, require_team_members_limit)

    {:ok, assign_on_open(socket, plan, assigns)}
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:open, false)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("validate", %{"free_trial_form" => params}, socket) do
    changeset =
      socket.assigns.free_trial
      |> FreeTrial.changeset(params)
      |> Map.put(:action, :validte)

    socket
    |> assign(:changeset, changeset)
    |> assign_form(changeset)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "submit",
        _params,
        %{assigns: %{changeset: %{valid?: false} = changeset}} = socket
      ) do
    changeset = Map.put(changeset, :action, :validte)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("submit", %{"free_trial_form" => params}, socket) do
    %{plan: plan, current_user: user, on_submit: on_submit, changeset: changeset} = socket.assigns

    case Subscriptions.start_free_trial(user.id, plan.id, changeset.changes) do
      {:ok, _subscription_user_plan} ->
        params = Map.merge(params, %{"user_id" => user.id, "plan_name" => plan.name_jp})
        Subscriptions.deliver_free_trial_apply_instructions(user, params)
        on_submit && on_submit.(plan)

        socket
        |> assign(:open, false)
        |> assign(:plan, nil)
        |> then(&{:noreply, &1})

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("close", _params, socket) do
    on_close = socket.assigns.on_close
    on_close && on_close.()

    {:noreply, assign(socket, :open, false)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_on_open(socket, nil, _assigns) do
    # プランが存在しない場合は開かない
    # TODO: 暫定仕様でのち対応予定（問い合わせになる想定）
    socket
    |> assign(:plan, nil)
    |> assign(:open, false)
  end

  defp assign_on_open(socket, plan, assigns) do
    free_trial = %FreeTrial{organization_plan: Subscriptions.organization_plan?(plan)}
    changeset = FreeTrial.changeset(free_trial, %{})

    socket
    |> assign(:plan, plan)
    |> assign(Map.take(assigns, ~w(on_submit on_close)a))
    |> assign(:changeset, changeset)
    |> assign(:free_trial, free_trial)
    |> assign_form(changeset)
    |> assign(:open, true)
  end

  defp get_plan_by_service(user, require_service_code) do
    current_plan = get_current_plan(user)

    Subscriptions.get_most_priority_free_trial_subscription_plan_by_service(
      require_service_code,
      current_plan
    )
  end

  defp get_plan_by_create_teams_limit(user, require_create_teams_limit) do
    current_plan = get_current_plan(user)

    Subscriptions.get_most_priority_free_trial_subscription_plan_by_teams_limit(
      require_create_teams_limit,
      current_plan
    )
  end

  defp get_plan_by_team_members_limit(user, require_team_members_limit) do
    current_plan = get_current_plan(user)

    Subscriptions.get_most_priority_free_trial_subscription_plan_by_members_limit(
      require_team_members_limit,
      current_plan
    )
  end

  defp get_current_plan(user) do
    current_user_plan = Subscriptions.get_user_subscription_user_plan(user.id)
    current_user_plan && current_user_plan.subscription_plan
  end
end
