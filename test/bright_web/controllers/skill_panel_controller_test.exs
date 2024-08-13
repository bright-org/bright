defmodule BrightWeb.SkillPanelControllerTest do
  use BrightWeb.ConnCase

  setup [:register_and_log_in_user]

  setup do
    skill_panel = insert(:skill_panel)
    insert(:skill_class, skill_panel: skill_panel, class: 1)
    insert(:skill_class, skill_panel: skill_panel, class: 2)
    %{skill_panel: skill_panel}
  end

  describe "GET /get_skill_panel/:id" do
    test "exists skill_panel", %{conn: conn, skill_panel: skill_panel} do
      conn = get(conn, "/get_skill_panel/#{skill_panel.id}")
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "スキルパネル:#{skill_panel.name}を取得しました"
      assert redirected_to(conn) == ~p"/panels/#{skill_panel.id}"
    end

    test "exists skill_panel and already get", %{conn: conn, skill_panel: skill_panel, user: user} do
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      conn = get(conn, "/get_skill_panel/#{skill_panel.id}")
      assert redirected_to(conn) == ~p"/panels/#{skill_panel.id}"
    end

    test "not exists skill panels", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get(conn, "/get_skill_panel/#{Ecto.ULID.generate()}")
      end
    end
  end
end
