defmodule BrightWeb.TeamCreateLiveComponent do
  @moduledoc """
  チーム作成モーダルのLiveComponent
  """
  use BrightWeb, :live_component

  import BrightWeb.ProfileComponents
  import BrightWeb.TeamComponents, only: [team_type_select_dropdown_menue: 1]

  alias Bright.Teams
  alias Bright.Teams.Team
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
      <div class="space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="flex items-center justify-between">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @impl true
  # add user eventでmy_team_liveからupdateが入ったときに実行されformの変更を保持する
  def update(assigns, %{assigns: %{team_form: %Phoenix.HTML.Form{}}} = socket) do
    {:ok, assign(socket, users: assigns.users)}
  end

  def update(%{action: :edit, team: team} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:modal_title, "チームを編集する（β）")
    |> assign(:submit, "チームを更新し、新規メンバーに招待メールを送る")
    |> assign(:selected_team_type, nil)
    |> assign_team_form(Teams.change_team(team))
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    team_changeset = Team.changeset(%Team{}, %{})

    socket
    |> assign(assigns)
    |> assign(:modal_title, "チームを作る（β）")
    |> assign(:submit, "チームを作成し、上記メンバーに招待を送る")
    |> assign(:selected_team_type, :general_team)
    |> assign_team_form(team_changeset)
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
    admin_count = Teams.count_admin_team(socket.assigns.current_user.id)
    save_team(socket, socket.assigns.action, team_params, admin_count, socket.assigns.plan)
  end

  def handle_event("select_team_type", %{"team_type" => team_type}, socket) do
    IO.puts(team_type)

    {
      :noreply,
      socket
      |> assign(:selected_team_type, String.to_atom(team_type))
      # |> push_patch()
    }
  end

  def save_team(socket, :new, team_params, count, %{create_teams_limit: limit})
      when count >= limit do
    msg =
      if limit == 1,
        do:
          "現在のプランでは、チームは1つまでが上限です<br /><br />「アップグレード」ボタンでチームアッププラン以上を<br />ご購入いただくと、作成できるチーム数を増やせます",
        else: "現在のプランでは、チームは#{limit}つまでが上限です"

    changeset =
      socket.assigns.team
      |> Team.registration_changeset(team_params)
      |> Ecto.Changeset.add_error(:name, msg)
      |> Map.put(:action, :validate)

    {:noreply, assign_team_form(socket, changeset)}
  end

  def save_team(socket, :new, team_params, count, nil)
      when count >= 1 do
    msg =
      "現在のプランでは、チームは1つまでが上限です<br /><br />「アップグレード」ボタンでチームアッププラン以上を<br />ご購入いただくと、作成できるチーム数を増やせます"

    changeset =
      socket.assigns.team
      |> Team.registration_changeset(team_params)
      |> Ecto.Changeset.add_error(:name, msg)
      |> Map.put(:action, :validate)

    {:noreply, assign_team_form(socket, changeset)}
  end

  def save_team(socket, :new, team_params, _count, _plan) do
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

  def save_team(%{assigns: assigns} = socket, :edit, team_params, _count, _plan) do
    current_member = assigns.team.users
    new_member = assigns.users
    newcomer = new_member -- current_member
    admin_user = assigns.current_user
    enable_functions = Teams.build_enable_functions(socket.assigns.selected_team_type)

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

  def send_invitation_mails_to_newcomer(team, admin_user, newcomer, member_user_attrs) do
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
end
