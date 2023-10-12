defmodule BrightWeb.UserJobProfileLiveTest do
  use BrightWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Index" do
    setup [:register_and_log_in_user]

    test "update user job setting", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mypage")

      # 求職するが選択されていて、詳細部分が表示されている
      assert index_live
             |> element("#user_settings div ul li a", "求職")
             |> render_click() =~ "希望する</span><span class=\"pb-1 w-24\">形態</span>"

      index_live
      |> form("#job_profile-form", user_job_profile: %{job_searching: false})
      |> render_submit()

      refute render(index_live) =~ "希望する</span><span class=\"pb-1 w-24\">形態</span>"
      assert render(index_live) =~ "保存しました"
    end
  end
end
