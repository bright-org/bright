defmodule BrightWeb.PageControllerTest do
  use BrightWeb.ConnCase
  import Mock

  describe "GET /" do
    test "shows debug page when env isn't prod", %{conn: conn} do
      with_mock(Bright.Utils.Env, [:passthrough], prod?: fn -> false end) do
        conn = get(conn, ~p"/")
        assert html_response(conn, 200) =~ "テストページ"
      end
    end

    test "redirects /mypage when env is prod", %{conn: conn} do
      with_mock(Bright.Utils.Env, [:passthrough], prod?: fn -> true end) do
        conn = get(conn, ~p"/")
        assert redirected_to(conn) == ~p"/mypage"
      end
    end
  end
end
