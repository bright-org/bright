defmodule BrightWeb.TeamInvitationConfirmController do
  use BrightWeb, :controller

  alias Bright.Teams

  def invitation_confirm(conn, %{"token" => invitation_token}) do
    case Teams.get_invitation_token(invitation_token) do
      {:ok, team_member_user} ->
        conn
        # 承認日の更新判定と更新
        |> decide_update_confirmed_at(team_member_user)
        # リダイレクト先の判定とリダイレクト
        |> decide_redirect_action(team_member_user)

      :error ->
        # token取得失敗時の挙動　運用カバーの為、エラーメッセージのみ表示してログイン画面に遷移
        conn
        |> put_flash(:error, "チーム招待の承認に失敗しました。")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  defp decide_update_confirmed_at(conn, team_member_user) do
    # ログインしていない　か　同一人でログインしている場合
    # かつ、
    # 未承認の場合は更新する
    if team_member_user.invitation_confirmed_at == nil &&
         (conn.assigns.current_user == nil ||
            conn.assigns.current_user.id == team_member_user.user_id) do
      {:ok, _team_member_user} = Teams.confirm_invitation(team_member_user)

      if conn.assigns.current_user == nil do
        # ログインしていない場合の承認メッセージフラッシュ
        conn
        |> put_flash(:info, "チームへの招待を承認しました。ログインして新しいチームを確認しましょう！")
      else
        # ログインしている場合の承認メッセージフラッシュ
        conn
        |> put_flash(:info, "チームへの招待を承認しました。新しいチームへようこそ！")
      end
    else
      # 更新しない
      conn
    end
  end

  defp decide_redirect_action(conn, team_member_user) do
    if conn.assigns.current_user != nil &&
         conn.assigns.current_user.id == team_member_user.user_id do
      # ログインしていて同一人の場合は該当チームのチームスキル分析へ遷移
      conn
      |> redirect(to: "/teams/#{team_member_user.team_id}")
    else
      # それ以外のケースはログイン画面へ遷移
      conn
      |> redirect(to: ~p"/users/log_in")
    end
  end
end
