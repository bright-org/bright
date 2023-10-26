defmodule BrightWeb.GraphLive.GraphsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory
  import Mock

  defp date_mock do
    {
      Date,
      [:passthrough],
      [
        utc_today: fn -> ~D[2023-10-25] end,
        new: fn y, m, d -> passthrough([y, m, d]) end
      ]
    }
  end

  describe "Show" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "shows content", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/graphs/#{skill_panel}")

      assert html =~ skill_panel.name

      assert show_live
             |> has_element?("#class_tab_1", skill_class.name)
    end

    test "shows content without parameters", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/graphs")

      assert html =~ skill_panel.name

      assert show_live
             |> has_element?("#class_tab_1", skill_class.name)
    end
  end

  describe "Show no skill panel" do
    setup [:register_and_log_in_user]

    test "show content with no skill panel message", %{conn: conn} do
      {:ok, show_live, html} = live(conn, ~p"/graphs")

      assert html =~ "スキルパネルがありません"

      show_live
      |> element("a", "スキルを選ぶ")
      |> render_click()

      {path, _} = assert_redirect(show_live)
      assert path == "/onboardings"
    end
  end

  # 成長グラフ
  # 成長グラフはJSでの描画のため渡しているdata属性を主な対象として確認している
  describe "Growth grapth" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    @base_data %{
      now: 0.0,
      labels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
      myself: [0, 0, 0, 0, 0, 0],
      futureEnabled: true,
      myselfSelected: "now"
    }

    test "shows growth graph", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")
        data = Jason.encode!(@base_data)
        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))
      end
    end

    test "shows now data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      insert(:skill_class_score, user: user, skill_class: skill_class, percentage: 50.0)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")
        data = Map.merge(@base_data, %{now: 50.0}) |> Jason.encode!()
        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))
      end
    end

    test "shows past data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      h_skill_class_1 =
        insert(:historical_skill_class,
          locked_date: ~D[2023-07-01],
          skill_panel_id: skill_panel.id,
          class: 1
        )

      h_skill_class_2 =
        insert(:historical_skill_class,
          locked_date: ~D[2023-04-01],
          skill_panel_id: skill_panel.id,
          class: 1
        )

      insert(:historical_skill_class_score,
        locked_date: ~D[2023-10-01],
        user: user,
        historical_skill_class: h_skill_class_1,
        percentage: 20.0
      )

      insert(:historical_skill_class_score,
        locked_date: ~D[2023-07-01],
        user: user,
        historical_skill_class: h_skill_class_2,
        percentage: 10.0
      )

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 10.0, 20.0, 0]
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))
      end
    end

    test "shows compared my data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      h_skill_class_1 =
        insert(:historical_skill_class,
          locked_date: ~D[2023-07-01],
          skill_panel_id: skill_panel.id,
          class: 1
        )

      h_skill_class_2 =
        insert(:historical_skill_class,
          locked_date: ~D[2023-04-01],
          skill_panel_id: skill_panel.id,
          class: 1
        )

      insert(:historical_skill_class_score,
        locked_date: ~D[2023-10-01],
        user: user,
        historical_skill_class: h_skill_class_1,
        percentage: 20.0
      )

      insert(:historical_skill_class_score,
        locked_date: ~D[2023-07-01],
        user: user,
        historical_skill_class: h_skill_class_2,
        percentage: 10.0
      )

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

        # 「自分と比較」を選択
        show_live
        |> element(~s(button[phx-click="compare_myself"]))
        |> render_click()

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 10.0, 20.0, 0],
            other: [0, 0, 0, 10.0, 20.0, 0],
            otherLabels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
            otherFutureEnabled: true,
            otherSelected: "2023.10"
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))

        # 比較側を１月ずらす操作
        show_live
        |> element(~s(button[phx-click="shift_timeline_past"][phx-value-id="other"]))
        |> render_click()

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 10.0, 20.0, 0],
            other: [0, 0, 0, 0, 10.0, 20.0],
            otherLabels: ["2022.10", "2023.1", "2023.4", "2023.7", "2023.10"],
            otherFutureEnabled: false,
            otherSelected: "2023.10"
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))
      end
    end
  end
end
