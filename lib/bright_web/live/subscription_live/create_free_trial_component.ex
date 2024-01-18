defmodule BrightWeb.SubscriptionLive.CreateFreeTrialComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions
  alias Bright.Subscriptions.FreeTrialForm, as: FreeTrial
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.BrightButtonComponents, only: [plan_upgrade_button: 1]

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
              <%= if is_nil(@subscription) do %>
                <%= if free_trial_available?(@current_user.id, @plan, @status) do %>
                  <p class="mt-2">
                    お試しいただくには、下記を入力し「開始する」ボタンをクリックしてください
                  </p>

                  <div class="pt-4">
                    <.form
                      for={@form}
                      id="free_trial_form"
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
                <% else %>
                  <div class="my-4">
                    <p class="mt-4">
                      <%= if is_nil(@status.trial_end_datetime) do %>
                        このプランはすでに選択済みです
                      <% else %>
                        このプランの無料トライアル期間は終了しています
                      <% end %>
                    </p>
                    <p class="mb-4">
                      下記「アップグレード」ボタンよりアップグレードできます（別タブで開きます）
                    </p>
                    <div class="flex justify-center">
                    <.plan_upgrade_button />
                    </div>
                  </div>
                <% end %>
              <% else %>
                <div class="my-4">
                  <%= if is_nil(@subscription.subscription_end_datetime) do %>
                    <p class="mt-4">
                      このプランはすでに選択済みです
                    </p>
                  <% else %>
                  <p class="mt-4">
                      このプランの無料トライアル期間は終了しています
                    </p>
                    <p class="mb-4">
                      下記「アップグレード」ボタンよりアップグレードできます（別タブで開きます）
                    </p>
                    <div class="flex justify-center">
                      <.plan_upgrade_button />
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    # TODO: 現契約プランと比較してチーム作成数などの制限数が落ちないプラン(かつ、URL指定されたplanに属するservice_codeを全て持つ）を取ること
    user = assigns.current_user

    plan =
      case Subscriptions.get_plan_by_plan_code(assigns.plan_code) do
        nil -> Subscriptions.get_plan_by_plan_code("hr_plan")
        plan -> plan
      end

    status = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())

    free_trial = %FreeTrial{organization_plan: Subscriptions.organization_plan?(plan)}
    changeset = FreeTrial.changeset(free_trial, %{})

    socket
    |> assign(assigns)
    |> assign(:plan, plan)
    |> assign(:subscription, exists_subscirption_plan(user.id, plan.plan_code))
    |> assign(:changeset, changeset)
    |> assign(:free_trial, free_trial)
    |> assign(:status, status)
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
        |> push_patch(to: socket.assigns.patch)
        |> then(&{:noreply, &1})

      false ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp exists_subscirption_plan(user_id, plan_code) do
    (Subscriptions.get_users_trialed_plans(user_id) ++
       Subscriptions.get_users_expired_plans(user_id))
    |> Enum.find(fn plan ->
      plan.subscription_plan.plan_code == plan_code && plan.subscription_status != :free_trial
    end)
  end

  defp free_trial_available?(user_id, plan, nil) do
    Subscriptions.free_trial_available?(user_id, plan.plan_code)
  end

  defp free_trial_available?(user_id, plan, status) do
    Subscriptions.free_trial_available?(user_id, plan.plan_code) &&
      status.subscription_plan.free_trial_priority < plan.free_trial_priority
  end
end
