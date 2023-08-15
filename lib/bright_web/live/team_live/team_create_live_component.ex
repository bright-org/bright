defmodule BrightWeb.TeamCreateLiveComponent do
  @moduledoc """
  チーム作成モーダルのLiveComponent
  """
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.Teams

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:users, [])

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("add_user", %{"search_word" => search_word}, socket) do
    current_users = socket.assigns.users
    user = Accounts.get_user_by_name_or_email(search_word)

    # メンバーユーザー一時リストに追加
    added_users =
      [user | current_users]
      |> Enum.reverse()

    {:noreply, assign(socket, :users, added_users)}
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    current_users = socket.assigns.users

    # メンバーユーザー一時リストから削除
    removed_users =
      current_users
      |> Enum.reject(fn x -> x.id == id end)

    {:noreply, assign(socket, :users, removed_users)}
  end

  @impl true
  def handle_event("create_team", %{"team_name" => team_name}, socket) do
    member_users = socket.assigns.users
    admin_user = socket.assigns.current_user

    case Teams.create_team_multi(team_name, admin_user, member_users) do
      {:ok, team, member_user_attrs} ->
        # 全メンバーのuserを一気にpreloadしたいのでteamを再取得
        preloaded_team = Teams.get_team!(team.id)

        # 招待したメンバー全員に招待メールを送信する。
        send_invitation_mail(preloaded_team, admin_user, member_user_attrs)

        # メール送信の成否に関わらず正常終了とする
        # TODO メール送信エラーを運用上検知する必要がないか?

        {:noreply,
         socket
         |> put_flash(:info, "チームを登録しました")
         # TODO チーム作成後は、作成したチームのチームスキル分析に遷移した方がよいか？
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset)}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply,
     socket
     |> redirect(to: ~p"/mypage")}
  end

  defp send_invitation_mail(preloaded_team, admin_user, member_user_attrs) do
    _results =
      preloaded_team.member_users
      |> Enum.map(fn member_user ->
        if !member_user.is_admin do
          # 管理者以外に招待メールを送信する
          # member_attrのリストから該当ユーザーのbase64_encode済tokenを取得してメールに添付
          member_user_attr =
            member_user_attrs
            |> Enum.find(fn member_user_attr ->
              member_user_attr.user_id == member_user.user_id
            end)

          Teams.deliver_invitation_email_instructions(
            admin_user,
            member_user.user,
            preloaded_team,
            member_user_attr.base64_encoded_token,
            &url(~p"/teams/invitation_confirm/#{&1}")
          )
        end
      end)
  end
end
