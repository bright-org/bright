defmodule BrightWeb.UserSettingsLive.CurrentSubscriptionPlanComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions
  alias Bright.CareerGroups
  alias Bright.Subscriptions.SubscriptionUserPlan

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="flex flex-col mt-8">
        <div id="current_subscription_plan" class="flex flex-col lg:flex-row lg:flex-wrap text-left">
        <%= for career_group <- @career_groups do %>
          <div class="w-full">
            <%= career_group.name %>
            <label class="flex items-center py-4">
              <span class="w-32">利用プラン</span>
              <span class="w-full"><%= Map.get(@plan, career_group.type) %></span>
              <div class="lg:ml-4 mt-1 py-4 w-full lg:w-fit">
                <%= if @user.type == career_group.type do %>
                <p class="bg-white block border-2 border-solid border-brightGray-600 font-bold px-2 py-1 rounded select-none text-center text-black w-full lg:w-28">
                  利用中
                </p>
                <% else %>
                <button
                  type="button"
                  phx-click="toggle"
                  phx-target={@myself}
                  phx-value-type={career_group.type}
                  class="bg-brightGray-900 block border border-solid border-brightGray-900 cursor-pointer font-bold px-2 py-1 rounded select-none text-center text-white w-full lg:w-28 hover:filter hover:brightness-[80%]"
                >
                  切り替える
                </button>
                <% end %>
              </div>
            </label>
          </div>
          <% end %>
        </div>
      </div>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    subscription_user_plan = Subscriptions.get_user_subscription_user_plan(assigns.user.id)
    current_datetime = NaiveDateTime.utc_now()

    career_groups =
      CareerGroups.list_career_groups()
      |> Enum.sort_by(&(&1.type != assigns.user.type))

    plan =
      case subscription_user_plan do
        %SubscriptionUserPlan{
          subscription_status: :free_trial,
          trial_start_datetime: trial_start,
          trial_end_datetime: nil,
          subscription_plan: %{name_jp: name_jp}
        }
        when current_datetime >= trial_start ->
          "#{name_jp}（無料トライアル中）"

        %SubscriptionUserPlan{
          subscription_status: :subscribing,
          subscription_plan: %{name_jp: name_jp}
        } ->
          name_jp

        _ ->
          "なし"
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(:plan, %{engineer: plan, medical: "なし"})
      |> assign(:career_groups, career_groups)

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle", %{"type" => type}, socket) do
    {:ok, user} = Bright.Accounts.update_user_type(socket.assigns.user, %{type: type})

    socket
    |> assign(:user, user)
    |> redirect(to: ~p"/mypage")
    |> then(&{:noreply, &1})
  end
end
