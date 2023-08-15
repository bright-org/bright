defmodule BrightWeb.TeamInvitationConfirmController do
  use BrightWeb, :controller

  alias Bright.Teams

  def invitation_confirm(conn, %{"token" => invitation_token}) do
    case Teams.verify_invitation_token(invitation_token) do
      {:ok, team_member_user} ->
        # 承認成功
        conn
        |> put_flash(:info, "チームへの招待を承認しました。新しいチームへようこそ！")
        |> redirect(to: "/teams/#{team_member_user.team_id}")

      :error ->
        # 承認失敗時の挙動　運用カバーの為、エラーメッセージのみ表示してログイン画面に遷移
        conn
        |> put_flash(:error, "チーム招待の承認に失敗しました。")
        |> redirect(to: ~p"/users/log_in")
    end
  end
end
