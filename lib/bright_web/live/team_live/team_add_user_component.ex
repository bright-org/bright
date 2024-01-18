defmodule BrightWeb.TeamLive.TeamAddUserComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.Subscriptions

  import BrightWeb.BrightCoreComponents, only: [action_button: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="min-w-[580px] pr-10 border-r border-r-brightGray-200 border-dashed">
    <!-- TODO α対象外
      <p>
        <span class="font-bold">気になる</span>からメンバーとして追加
      </p>

      <p>
        <span class="font-bold">関わっているチーム</span>からサブチームとして追加
      </p>
    -->
      <div class="flex items-center">
        <form
          id="add_user_form"
          phx-target={@myself}
          phx-submit="add_user"
        >
          <p class="pb-2 text-base">
            <span class="font-bold">Brightハンドル名もしくはメールアドレス</span>からメンバーとして追加
          </p>
          <input
            id="search_word"
            name="search_word"
            type="autocomplete"
            placeholder="ハンドル名もしくはメールアドレスを入力してください"
            class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-[390px]"
            phx-change="change_add_user"
            phx-target={@myself}
            value={@search_word}
          />
          <.action_button type="submit" class="ml-2.5">
            追加
          </.action_button>
        </form>
      </div>
      <div :if={@search_word_error != nil}>
        <p class= "text-error text-xs"><%= Phoenix.HTML.raw(@search_word_error) %></p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:search_word, nil)
    |> assign(:search_word_error, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{trial_subscription_plan: _subscription_plan}, socket) do
    # 無料トライアルを開始して戻った際に実行されるupdate
    # planは上から更新されるためアサイン不要
    {:ok, assign(socket, :search_word_error, nil)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("change_add_user", %{"search_word" => search_word}, socket) do
    {:noreply, assign(socket, :search_word, search_word)}
  end

  def handle_event("add_user", _params, socket) do
    search_word = socket.assigns.search_word

    socket
    |> validate_search_word(search_word)
    |> validate_search_user(search_word)
    |> validate_add_user()
    |> add_user()
    |> then(&{:noreply, &1})
  end

  # 検索ワードのバリデーション
  defp validate_search_word(socket, search_word) do
    if is_nil(search_word) || search_word == "" do
      {:error, assign(socket, search_word_error: "検索条件を入力してください")}
    else
      {:ok, socket}
    end
  end

  # 検索結果のバリデーション
  defp validate_search_user({:error, socket}, _search_word), do: {:error, socket}

  defp validate_search_user({:ok, socket}, search_word) do
    user = Accounts.get_user_by_name_or_email(search_word)

    cond do
      is_nil(user) ->
        {:error, assign(socket, :search_word_error, "該当のユーザーが見つかりませんでした")}

      user.id == socket.assigns.current_user.id ->
        {:error, assign(socket, search_word_error: "チーム作成者は自動的に管理者として追加されます")}

      true ->
        {:ok, socket, user}
    end
  end

  # 検索結果を追加する時のバリデーション
  defp validate_add_user({:error, socket}), do: {:error, socket}

  defp validate_add_user({:ok, socket, user}) do
    %{users: selected_users, plan: plan, id: id} = socket.assigns

    # current_members_count: チームメンバー数, 管理者がselected_usersには含まれないため+1をしている
    current_members_count = Enum.count(selected_users) + 1
    limit = Subscriptions.get_team_members_limit(plan)

    cond do
      id_duplidated_user?(selected_users, user) ->
        {:error, assign(socket, :search_word_error, "対象のユーザーは既に追加されています")}

      member_limit?(current_members_count, limit) ->
        message = member_limit_message(limit)
        open_free_trial_modal(current_members_count + 1, id)
        {:error, assign(socket, :search_word_error, message)}

      true ->
        {:ok, socket, user}
    end
  end

  defp add_user({:error, socket}), do: socket

  defp add_user({:ok, socket, user}) do
    # メンバーユーザー一時リストに追加
    notify_parent({:add, socket.assigns.users ++ [user]})

    socket
    |> assign(:search_word, nil)
    |> assign(:search_word_error, nil)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp id_duplidated_user?(users, user) do
    users |> Enum.find(fn u -> user.id == u.id end) |> is_nil() |> then(&(!&1))
  end

  defp member_limit?(members_count, limit) do
    members_count >= limit
  end

  defp member_limit_message(limit) do
    "現在のプランでは、メンバーは#{limit}名まで（管理者含む）が上限です<br /><br />「アップグレード」ボタンから上位プランをご購入いただくと<br />メンバー数を増やせます"
  end

  defp open_free_trial_modal(require_limit, id) do
    send_update(BrightWeb.SubscriptionLive.FreeTrialRecommendationComponent,
      id: "free_trial_recommendation_modal",
      open: true,
      team_members_limit: require_limit,
      on_submit: fn subscription_plan ->
        # 無料トライアル開始後はエラーメッセージを削除して表示
        send_update(__MODULE__, id: id, trial_subscription_plan: subscription_plan)
        # rootのLiveViewにplan変更通知
        send(self(), {:plan_changed, subscription_plan})
      end
    )
  end
end
