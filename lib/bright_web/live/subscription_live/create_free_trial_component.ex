defmodule BrightWeb.SubscriptionLive.CreateFreeTrialComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions
  alias Bright.Subscriptions.FreeTrialForm, as: FreeTrial
  import BrightWeb.BrightButtonComponents, only: [plan_upgrade_button: 1]
  import BrightWeb.Forms, only: [free_trial_form: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="free_trial_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-8 shadow text-sm w-full">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
                β期間終了までお試しいただけます
              </span>
            </h2>
            <p class="mt-2" :if={@plan.plan_code == "hr_plan"}>
              ※現在、面談調整とチャットまでお試しいただけます
            </p>
            <p class="mt-2">
              (お試し期間以降もご利用される場合はプランのアップグレードが必要です)
            </p>
            <div class="mt-8">
              <h3 class="font-bold text-xl">
                <%= @plan.name_jp %>プラン
              </h3>

              <div :if={@free_trial_available?} class="mt-2">
                <p class="mt-2">
                  お試しいただくには、下記を入力し「開始する」ボタンをクリックしてください
                </p>

                <div class="pt-4">
                  <.free_trial_form
                    id="free_trial_form"
                    form={@form}
                    phx_change={JS.push("validate", target: @myself)}
                    phx_submit={JS.push("submit", target: @myself)} />
                </div>
              </div>

              <div class="my-4">
                <p :if={@invalid_reason == :already_available} class="mt-4">
                  このプランはすでに選択済みです
                </p>

                <p :if={@invalid_reason == :already_used_once} class="mt-4">
                  このプランの無料トライアル期間は終了しています
                </p>

                <p :if={@invalid_reason == :no_plan} class="mt-4">
                  無料トライアルの対象プランがありません
                </p>

                <p class="my-4">
                  下記「プランのアップグレード」ボタンよりアップグレードできます（別タブで開きます）
                </p>
                <div class="flex justify-center">
                  <.plan_upgrade_button />
                </div>
              </div>
            </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    user = assigns.current_user

    plan =
      case Subscriptions.get_plan_by_plan_code(assigns.plan_code) do
        nil -> Subscriptions.get_plan_by_plan_code("hr_plan")
        plan -> plan
      end

    free_trial = %FreeTrial{organization_plan: Subscriptions.organization_plan?(plan)}
    changeset = FreeTrial.changeset(free_trial, %{})

    {free_trial_available?, invalid_reason} =
      Subscriptions.free_trial_available?(user.id, plan.plan_code)

    socket
    |> assign(assigns)
    |> assign(:plan, plan)
    |> assign(free_trial_available?: free_trial_available?, invalid_reason: invalid_reason)
    |> assign(:changeset, changeset)
    |> assign(:free_trial, free_trial)
    |> assign_form(changeset)
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

  def handle_event("submit", %{"free_trial_form" => params}, socket) do
    user = socket.assigns.current_user
    plan = socket.assigns.plan

    changeset =
      socket.assigns.free_trial
      |> FreeTrial.changeset(params)
      |> Map.put(:action, :validte)

    case changeset.valid? do
      true ->
        {:ok, _subscription_user_plan} =
          Subscriptions.start_free_trial(user.id, plan.id, changeset.changes)

        params = Map.merge(params, %{"user_id" => user.id, "plan_name" => plan.name_jp})
        Subscriptions.deliver_free_trial_apply_instructions(user, params)

        socket
        |> put_flash(:info, "無料トライアルを開始しました")
        |> push_navigate(to: socket.assigns.navigate)
        |> then(&{:noreply, &1})

      false ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
