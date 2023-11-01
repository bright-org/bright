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

  defp create_historical_skill_class(skill_panel, locked_date) do
    insert(:historical_skill_class,
      skill_panel_id: skill_panel.id,
      locked_date: locked_date,
      class: 1
    )
  end

  defp create_historical_skill_class_score(user, historical_skill_class, locked_date, percentage) do
    insert(:historical_skill_class_score,
      user: user,
      historical_skill_class: historical_skill_class,
      locked_date: locked_date,
      percentage: percentage
    )
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

  # スキルジェム
  # スキルジェムはJSでの描画のため渡しているdata属性を主な対象として確認している
  describe "Skill Gem" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    # スキルユニット用意
    setup %{skill_class: skill_class} do
      # positionは並びでindexするため確認のため適当な数値をいれている
      skill_units =
        [
          {"ユニット１", 90},
          {"ユニット２", 10},
          {"ユニット３", 40}
        ]
        |> Enum.map(fn {name, position} ->
          skill_unit = insert(:skill_unit, name: name)

          insert(:skill_class_unit,
            skill_class: skill_class,
            skill_unit: skill_unit,
            position: position
          )
        end)

      %{skill_units: skill_units}
    end

    test "shows gem links", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

      data_links =
        [
          "/panels/#{skill_panel.id}?class=1&#unit-1",
          "/panels/#{skill_panel.id}?class=1&#unit-2",
          "/panels/#{skill_panel.id}?class=1&#unit-3"
        ]
        |> Jason.encode!()

      data_labels =
        [
          "ユニット２",
          "ユニット３",
          "ユニット１"
        ]
        |> Jason.encode!()

      assert has_element?(show_live, ~s(#skill-gem[data-links='#{data_links}']))
      assert has_element?(show_live, ~s(#skill-gem[data-labels='#{data_labels}']))
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
      h_skill_class_1 = create_historical_skill_class(skill_panel, ~D[2023-07-01])

      h_skill_class_2 = create_historical_skill_class(skill_panel, ~D[2023-04-01])

      create_historical_skill_class_score(
        user,
        h_skill_class_1,
        ~D[2023-10-01],
        20.0
      )

      create_historical_skill_class_score(
        user,
        h_skill_class_2,
        ~D[2023-07-01],
        10.0
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
      h_skill_class_1 = create_historical_skill_class(skill_panel, ~D[2023-07-01])

      h_skill_class_2 = create_historical_skill_class(skill_panel, ~D[2023-04-01])

      create_historical_skill_class_score(
        user,
        h_skill_class_1,
        ~D[2023-10-01],
        20.0
      )

      create_historical_skill_class_score(
        user,
        h_skill_class_2,
        ~D[2023-07-01],
        10.0
      )

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

        # 「自分と比較」を選択
        show_live
        |> element(~s(button[phx-click="compare_myself"]))
        |> render_click()

        assert has_element?(show_live, ~s(#timeline-bar-compared))

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

        # 比較側を１月ずらす確認
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

        # 比較対象を閉じる確認
        show_live
        |> element(~s(button[phx-click="timeline_bar_close_button_click"]))
        |> render_click()

        refute has_element?(show_live, ~s(#timeline-bar-compared))
      end
    end

    test "shows compared user data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      h_skill_class_1 = create_historical_skill_class(skill_panel, ~D[2023-07-01])

      h_skill_class_2 = create_historical_skill_class(skill_panel, ~D[2023-04-01])

      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)

      create_historical_skill_class_score(user_2, h_skill_class_1, ~D[2023-10-01], 20.0)
      create_historical_skill_class_score(user_2, h_skill_class_2, ~D[2023-07-01], 10.0)

      # 比較対象ユーザーとチームメンバー化
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

        # 「他者と比較」を選択してuser_2を選択
        show_live
        |> element(~s(#related-user-card-related-user-card-compare a[phx-value-tab_name="team"]))
        |> render_click()

        show_live
        |> element(~s(a[phx-click="click_on_related_user_card_compare"]), user_2.name)
        |> render_click()

        assert has_element?(show_live, ~s(#timeline-bar-compared))
        assert has_element?(show_live, ~s(#compared-user-display), user_2.name)

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 0, 0, 0],
            other: [0, 0, 0, 10.0, 20.0, 0],
            otherLabels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
            otherFutureEnabled: true,
            otherSelected: "2023.10"
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))

        # 比較側を１月ずらす確認
        show_live
        |> element(~s(button[phx-click="shift_timeline_past"][phx-value-id="other"]))
        |> render_click()

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 0, 0, 0],
            other: [0, 0, 0, 0, 10.0, 20.0],
            otherLabels: ["2022.10", "2023.1", "2023.4", "2023.7", "2023.10"],
            otherFutureEnabled: false,
            otherSelected: "2023.10"
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))

        # 比較対象を閉じる確認
        show_live
        |> element(~s(button[phx-click="timeline_bar_close_button_click"]))
        |> render_click()

        refute has_element?(show_live, ~s(#timeline-bar-compared))
        refute has_element?(show_live, ~s(#compared-user-display))
      end
    end
  end
end
