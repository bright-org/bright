defmodule BrightWeb.TeamCreateLiveComponent do
  @moduledoc """
  チーム作成モーダルのLiveComponent
  """
  use BrightWeb, :live_component

  import BrightWeb.ProfileComponents
  import BrightWeb.TeamComponents, only: [team_type_select_dropdown_menue: 1]

  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.Subscriptions
  alias BrightWeb.TeamLive.TeamAddUserComponent
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  @doc """
  Renders a simple form for tema create.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def team_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="w-full space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="flex items-center justify-between">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @impl true
  def update(%{changeset: changeset, trial_subscription_plan: _plan}, socket) do
    # 無料トライアルを開始して戻った際に実行されるupdate
    # planはLiveViewから別途更新されるためアサイン不要
    {:ok, assign_team_form(socket, changeset)}
  end

  def update(assigns, %{assigns: %{team_form: %Phoenix.HTML.Form{}}} = socket) do
    # add user eventでmy_team_liveからupdateが入ったときに実行されformの変更を保持する
    # plan更新時(無料トライアル開始時)にも本updateに入るためアサインがあれば更新
    {:ok,
     socket
     |> assign(users: assigns.users)
     |> update(:plan, &(Map.get(assigns, :plan) || &1))}
  end

  def update(%{action: :edit, team: team} = assigns, socket) do
    socket
    |> assign(assigns)
    |> validate_user_grant()
    |> assign(:modal_title, "チームを編集する")
    |> assign(:right_title, "編集後のチーム")
    |> assign(:submit, "チームを更新し、新規メンバーに招待メールを送る")
    |> assign(:selected_team_type, Teams.get_team_type_by_team(team))
    |> assign_team_form(Teams.change_team(team))
    |> assign(:not_invitation_confirmed_users, not_invitation_confirmed_users(team.member_users))
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    team_changeset = Team.changeset(%Team{}, %{})

    socket
    |> assign(assigns)
    |> assign(:modal_title, "チームを作る")
    |> assign(:right_title, "新しいチーム")
    |> assign(:submit, "チームを作成し、上記メンバーに招待を送る")
    |> assign(:selected_team_type, :general_team)
    |> assign_team_form(team_changeset)
    |> assign(:not_invitation_confirmed_users, %{})
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("validate_team", %{"team" => team_params}, socket) do
    changeset =
      socket.assigns.team
      |> Team.registration_changeset(team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_team_form(socket, changeset)}
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    # メンバーユーザー一時リストから削除
    removed_users = Enum.reject(socket.assigns.users, fn x -> x.id == id end)
    {:noreply, assign(socket, :users, removed_users)}
  end

  def handle_event("delete_team", %{"id" => id}, socket) do
    {:ok, _} =
      Teams.get_team!(id)
      |> Teams.update_team(%{disabled_at: NaiveDateTime.utc_now()})

    socket
    |> put_flash(:info, "チームを削除しました")
    |> push_navigate(to: ~p"/teams")
    |> then(&{:noreply, &1})
  end

  def handle_event("create_team", %{"team" => team_params}, socket) do
    %{action: action, selected_team_type: team_type} = socket.assigns

    validate_teams_limit(socket, action, team_type, team_params)
    |> case do
      {:ok, socket} ->
        save_team(socket, action, team_params)

      {:ng, socket} ->
        {:noreply, socket}
    end
  end

  def handle_event(
        "select_team_type",
        %{"team_type" => team_type},
        %{assigns: %{action: :new}} = socket
      ) do
    {:noreply, assign(socket, :selected_team_type, String.to_atom(team_type))}
  end

  defp validate_teams_limit(socket, :new, :hr_support_team, team_params) do
    %{current_user: user, plan: plan, id: id, team: team} = socket.assigns

    team_count = Teams.count_admin_hr_support_team(user.id)
    limit = Subscriptions.get_create_enable_hr_functions_teams_limit(plan)

    if team_count >= limit do
      # 上限になっており追加できないケース
      changeset = changeset_with_hr_support_teams_limit_msg(team, team_params, limit)
      open_free_trial_modal(team_count + 1, team, team_params, "hr_support_team", id)

      {:ng, assign_team_form(socket, changeset)}
    else
      {:ok, socket}
    end
  end

  defp validate_teams_limit(socket, :new, team_type, team_params) do
    %{current_user: user, plan: plan, id: id, team: team} = socket.assigns

    team_count = Teams.count_admin_team_without_hr_support_team(user.id)
    limit = Subscriptions.get_create_teams_limit(plan)

    if team_count >= limit do
      # 上限になっており追加できないケース
      changeset = changeset_with_teams_limit_msg(team, team_params, limit)
      open_free_trial_modal(team_count + 1, team, team_params, team_type, id)

      {:ng, assign_team_form(socket, changeset)}
    else
      {:ok, socket}
    end
  end

  defp validate_teams_limit(socket, _action, _team_type, _team_params) do
    # 編集時はチーム数上限変更処理は何もしない
    # チームタイプは変更できないため、変更に伴う検証も必要としない
    {:ok, socket}
  end

  defp save_team(socket, :new, team_params) do
    member_users = socket.assigns.users
    admin_user = socket.assigns.current_user
    enable_functions = Teams.build_enable_functions(socket.assigns.selected_team_type)

    case Teams.create_team_multi(team_params["name"], admin_user, member_users, enable_functions) do
      {:ok, team, member_user_attrs} ->
        # 全メンバーのuserを一気にpreloadしたいのでteamを再取得
        preloaded_team = Teams.get_team_with_member_users!(team.id)

        # 招待したメンバー全員に招待メールを送信する。
        send_invitation_mails(preloaded_team, admin_user, member_user_attrs)

        # メール送信の成否に関わらず正常終了とする
        # TODO メール送信エラーを運用上検知する必要がないか?

        {:noreply,
         socket
         |> put_flash(:info, "チームを登録しました")
         # TODO チーム作成後は、作成したチームのチームスキル分析に遷移した方がよいか？
         |> redirect(to: ~p"/teams/#{team}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset)}
    end
  end

  defp save_team(%{assigns: assigns} = socket, :edit, team_params) do
    current_member = assigns.team.users
    new_member = assigns.users
    newcomer = new_member -- current_member
    admin_user = assigns.current_user

    enable_functions =
      socket.assigns.selected_team_type
      |> Teams.build_enable_functions()
      |> Map.new(fn {k, v} -> {to_string(k), to_string(v)} end)

    team_params =
      team_params
      |> Map.merge(enable_functions)

    case Teams.update_team_multi(assigns.team, team_params, admin_user, newcomer, new_member) do
      {:ok, team, member_user_attrs} ->
        # 新規招待したメンバー全員に招待メールを送信する。
        send_invitation_mails_to_newcomer(team, admin_user, newcomer, member_user_attrs)

        # メール送信の成否に関わらず正常終了とする
        # TODO メール送信エラーを運用上検知する必要がないか?

        {:noreply,
         socket
         |> put_flash(:info, "チームを更新しました")
         # TODO チーム作成後は、作成したチームのチームスキル分析に遷移した方がよいか？
         |> redirect(to: ~p"/teams/#{team}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset)}
    end
  end

  defp send_invitation_mails(team, admin_user, member_user_attrs) do
    team.member_users
    |> Enum.each(fn member_user ->
      if !member_user.is_admin do
        send_invitation_mail(team, admin_user, member_user, member_user_attrs)
      end
    end)
  end

  defp send_invitation_mails_to_newcomer(team, admin_user, newcomer, member_user_attrs) do
    newcomer
    |> Enum.map(&%{user_id: &1.id, user: &1})
    |> Enum.each(fn member_user ->
      send_invitation_mail(team, admin_user, member_user, member_user_attrs)
    end)
  end

  defp send_invitation_mail(team, admin_user, member_user, member_user_attrs) do
    member_user_attr =
      member_user_attrs
      |> Enum.find(fn member_user_attr ->
        member_user_attr.user_id == member_user.user_id
      end)

    # 管理者以外に招待メールを送信する
    # member_attrのリストから該当ユーザーのbase64_encode済tokenを取得してメールに添付

    Teams.deliver_invitation_email_instructions(
      admin_user,
      member_user.user,
      team,
      member_user_attr.base64_encoded_token,
      &url(~p"/teams/invitation_confirm/#{&1}")
    )
  end

  defp assign_team_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :team_form, to_form(changeset))
  end

  defp changeset_with_teams_limit_msg(team, params, limit) do
    msg =
      "現在のプランでは、チーム数の上限は#{limit}です<br /><br />「アップグレード」ボタンから上位プランをご購入いただくと<br />作成できるチーム数を増やせます"

    team
    |> Team.registration_changeset(params)
    |> Ecto.Changeset.add_error(:name, msg)
    |> Map.put(:action, :validate)
  end

  defp changeset_with_hr_support_teams_limit_msg(team, params, limit) do
    msg =
      "現在のプランでは、採用・支援チーム数の上限は#{limit}です<br /><br />「アップグレード」ボタンから上位プランをご購入いただくと<br />作成できるチーム数を増やせます"

    team
    |> Team.registration_changeset(params)
    |> Ecto.Changeset.add_error(:name, msg)
    |> Map.put(:action, :validate)
  end

  defp open_free_trial_modal(require_limit, team, team_params, "hr_support_team", id) do
    send_update(BrightWeb.SubscriptionLive.FreeTrialRecommendationComponent,
      id: "free_trial_recommendation_modal",
      open: true,
      create_enable_hr_functions_teams_limit: require_limit,
      on_submit: fn subscription_plan ->
        # 無料トライアル開始後はエラーメッセージを削除して表示
        changeset = Team.registration_changeset(team, team_params)

        send_update(__MODULE__,
          id: id,
          changeset: changeset,
          trial_subscription_plan: subscription_plan
        )

        # rootのLiveViewにplan変更通知
        send(self(), {:plan_changed, subscription_plan})
      end
    )
  end

  defp open_free_trial_modal(require_limit, team, team_params, _team_type, id) do
    send_update(BrightWeb.SubscriptionLive.FreeTrialRecommendationComponent,
      id: "free_trial_recommendation_modal",
      open: true,
      create_teams_limit: require_limit,
      on_submit: fn subscription_plan ->
        # 無料トライアル開始後はエラーメッセージを削除して表示
        changeset = Team.registration_changeset(team, team_params)

        send_update(__MODULE__,
          id: id,
          changeset: changeset,
          trial_subscription_plan: subscription_plan
        )

        # rootのLiveViewにplan変更通知
        send(self(), {:plan_changed, subscription_plan})
      end
    )
  end

  defp validate_user_grant(socket) do
    current_user = socket.assigns.current_user
    team = socket.assigns.team

    if Teams.is_admin?(team, current_user) do
      socket
    else
      raise Bright.Exceptions.ForbiddenResourceError
    end
  end

  defp not_invitation_confirmed_users(member_users) do
    Enum.filter(member_users, &is_nil(&1.invitation_confirmed_at))
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, x.user_id, not_invitation_confirmed_string(x.inserted_at))
    end)
  end

  defp not_invitation_confirmed_string(inserted_at) do
    diff_day =
      Date.diff(Date.utc_today(), inserted_at) > Bright.Teams.get_invitation_validity_ago()

    if diff_day, do: "期限切れ未承認", else: "未承認"
  end
end
