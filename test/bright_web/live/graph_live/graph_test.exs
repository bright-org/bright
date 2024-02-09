defmodule BrightWeb.GraphLive.GraphsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory
  import Mock

  alias Bright.Repo
  alias Bright.Teams.TeamMemberUsers

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

  defp create_historical_skill_units(skill_panel, skill_units, locked_date) do
    h_skill_class = create_historical_skill_class(skill_panel, locked_date)

    h_skill_units =
      Enum.map(skill_units, fn skill_unit ->
        insert(
          :historical_skill_unit,
          trace_id: skill_unit.trace_id,
          locked_date: locked_date
        )
      end)

    Enum.each(
      h_skill_units,
      &insert(
        :historical_skill_class_unit,
        historical_skill_class: h_skill_class,
        historical_skill_unit: &1
      )
    )

    h_skill_units
  end

  defp create_historical_skill_unit_scores(historical_skill_units, percentages, user, locked_date) do
    Enum.zip(historical_skill_units, percentages)
    |> Enum.map(fn {h_skill_unit, percentage} ->
      insert(:historical_skill_unit_score,
        user: user,
        historical_skill_unit: h_skill_unit,
        locked_date: locked_date,
        percentage: percentage
      )
    end)
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
      # 並びでindexにする確認としてpositionに適当な数値をいれている
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
        |> Enum.sort_by(& &1.position, :asc)
        |> Enum.map(& &1.skill_unit)

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

    test "shows compared my data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_units: skill_units
    } do
      percentages_202307 = [10, 11, 12]
      percentages_202310 = [20, 21, 22]

      [
        {~D[2023-07-01], percentages_202307},
        {~D[2023-10-01], percentages_202310}
      ]
      |> Enum.each(fn {locked_date, percentages} ->
        locked_date_master = Timex.shift(locked_date, months: -3)

        h_skill_units =
          create_historical_skill_units(skill_panel, skill_units, locked_date_master)

        create_historical_skill_unit_scores(h_skill_units, percentages, user, locked_date)
      end)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

        # 「自分と比較」を選択
        show_live
        |> element(~s(button[phx-click="compare_myself"]))
        |> render_click()

        # 「現在」表示のため一致で1データ表示のみ
        # - 「現在」スコアはないため0.0となる
        data = [[0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))

        # 比較対象側 2023.10を選択
        show_live
        |> element(
          ~s(button[phx-click="timeline_bar_button_click"][phx-value-id="other"][phx-value-date="2023.10"])
        )
        |> render_click()

        data = [[20.0, 21.0, 22.0], [0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))

        # 比較対象を閉じる
        show_live
        |> element(~s(button[phx-click="timeline_bar_close_button_click"]))
        |> render_click()

        data = [[0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))
      end
    end

    test "shows compared user data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_units: skill_units
    } do
      # 他者のテストデータ準備
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      percentages_202307 = [10, 11, 12]
      percentages_202310 = [20, 21, 22]

      [
        {~D[2023-07-01], percentages_202307},
        {~D[2023-10-01], percentages_202310}
      ]
      |> Enum.each(fn {locked_date, percentages} ->
        locked_date_master = Timex.shift(locked_date, months: -3)

        h_skill_units =
          create_historical_skill_units(skill_panel, skill_units, locked_date_master)

        create_historical_skill_unit_scores(h_skill_units, percentages, user, locked_date)
        create_historical_skill_unit_scores(h_skill_units, percentages, user_2, locked_date)
      end)

      # テスト
      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")

        # 以下、他者と比較とタイムライン操作による更新、解除まで一覧の期待値を確認

        # 1. 「他者と比較」を選択
        show_live
        |> element(~s(#related-user-card-related-user-card-compare a[phx-value-tab_name="team"]))
        |> render_click()

        show_live
        |> element(~s(a[phx-click="click_on_related_user_card_compare"]), user_2.name)
        |> render_click()

        # NOTE: 「現在」スコアはないため0.0となる
        data = [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))

        # 2. 自身のタイムラインを2023.10に変更
        show_live
        |> element(
          ~s(button[phx-click="timeline_bar_button_click"][phx-value-id="myself"][phx-value-date="2023.10"])
        )
        |> render_click()

        data = [[20.0, 21.0, 22.0], [0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))

        # 3. 比較対象のタイムラインを2023.7に変更
        show_live
        |> element(
          ~s(button[phx-click="timeline_bar_button_click"][phx-value-id="other"][phx-value-date="2023.7"])
        )
        |> render_click()

        data = [[20.0, 21.0, 22.0], [10.0, 11.0, 12.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))

        # 4. 比較対象を閉じる
        show_live
        |> element(~s(button[phx-click="timeline_bar_close_button_click"]))
        |> render_click()

        data = [[20.0, 21.0, 22.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))
      end
    end

    test "shows compared user with parameter", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)

      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}?compare=#{user_2.name}")
        data = [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))
      end
    end

    test "access control, not shows unauthorized user", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")
        # 「他者と比較」を選択
        show_live
        |> element(~s(#related-user-card-related-user-card-compare a[phx-value-tab_name="team"]))
        |> render_click()

        # user_2をチームから除外して参照不可状況をつくっている
        # テスト便宜上、画面を出してから削除している
        Repo.get_by(TeamMemberUsers, team_id: team.id, user_id: user_2.id) |> Repo.delete!()

        show_live
        |> element(~s(a[phx-click="click_on_related_user_card_compare"]), user_2.name)
        |> render_click()

        # 比較対象に追加されていないこと
        data = [[0.0, 0.0, 0.0]] |> Jason.encode!()
        assert has_element?(show_live, ~s(#skill-gem[data-data='#{data}']))
      end
    end

    test "access control, not shows unauthorized user with parameter ", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)

      with_mocks([date_mock()]) do
        # URL指定なので404相当エラーで返す
        assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
          live(conn, ~p"/graphs/#{skill_panel}?compare=#{user_2.name}")
        end
      end
    end
  end

  # 成長パネル
  # 成長パネルはJSでの描画のため渡しているdata属性を主な対象として確認している
  describe "Growth panel" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    # 現在データまでの25日分+5日分のnilデータ
    # （`date_mock`で10/25を指定している + 表示のための5つのnil）
    @nil_25 Enum.map(1..25, fn _ -> nil end) ++ [nil, nil, nil, nil, nil]

    @base_data %{
      labels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
      myself: [0, 0, 0, 0, 0, 0],
      myselfNow: 0.0,
      futureDisplay: true,
      myselfSelected: "now",
      other: [],
      otherLabels: [],
      otherFutureDisplay: nil,
      otherSelected: nil,
      otherNow: nil,
      comparedOther: nil,
      displayProgress: false,
      progress: []
    }

    @base_data_on_now %{
      labels: ["2023.4", "2023.7", "2023.10", "2024.1"],
      myself: [0, 0, 0, 0, 0],
      myselfNow: 0.0,
      futureDisplay: true,
      myselfSelected: "now",
      other: [],
      otherLabels: [],
      otherFutureDisplay: nil,
      otherSelected: nil,
      otherNow: nil,
      comparedOther: nil,
      displayProgress: true,
      progress: @nil_25
    }

    test "shows growth graph", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")
        data = Jason.encode!(@base_data_on_now)
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
        data = Map.merge(@base_data_on_now, %{myselfNow: 50.0}) |> Jason.encode!()
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
          Map.merge(@base_data_on_now, %{
            myself: [0, 0, 10.0, 20.0, 0]
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
            otherNow: 0.0,
            otherLabels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
            otherFutureDisplay: true,
            otherSelected: "now",
            comparedOther: false
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))

        # 比較側を１月ずらす確認
        show_live
        |> element(
          ~s(div[data-size="pc"] button[phx-click="shift_timeline_past"][phx-value-id="other"])
        )
        |> render_click()

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 10.0, 20.0, 0],
            other: [0, 0, 0, 0, 10.0, 20.0],
            otherNow: nil,
            otherLabels: ["2022.10", "2023.1", "2023.4", "2023.7", "2023.10"],
            otherFutureDisplay: false,
            otherSelected: "now",
            comparedOther: false
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
            myselfNow: 0.0,
            other: [0, 0, 0, 10.0, 20.0, 0],
            otherNow: 0,
            otherLabels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
            otherFutureDisplay: true,
            otherSelected: "now",
            comparedOther: true
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))

        # 比較側を１月ずらす確認
        show_live
        |> element(
          ~s(div[data-size="pc"] button[phx-click="shift_timeline_past"][phx-value-id="other"])
        )
        |> render_click()

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 0, 0, 0],
            myselfNow: 0.0,
            other: [0, 0, 0, 0, 10.0, 20.0],
            otherNow: nil,
            otherLabels: ["2022.10", "2023.1", "2023.4", "2023.7", "2023.10"],
            otherFutureDisplay: false,
            otherSelected: "now",
            comparedOther: true
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

    test "shows compared user with parameter", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)

      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}?compare=#{user_2.name}")

        assert has_element?(show_live, ~s(#timeline-bar-compared))
        assert has_element?(show_live, ~s(#compared-user-display), user_2.name)

        data =
          Map.merge(@base_data, %{
            myself: [0, 0, 0, 0, 0, 0],
            myselfNow: 0.0,
            other: [0, 0, 0, 0, 0, 0],
            otherNow: 0,
            otherLabels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
            otherFutureDisplay: true,
            otherSelected: "now",
            comparedOther: true
          })
          |> Jason.encode!()

        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))
      end
    end

    test "shows progress data", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      insert(:skill_class_score_log,
        user: user,
        skill_class: skill_class,
        percentage: 10.0,
        date: ~D[2023-10-01]
      )

      insert(:skill_class_score_log,
        user: user,
        skill_class: skill_class,
        percentage: 20.0,
        date: ~D[2023-10-05]
      )

      # 当日分はnowをみるので含まれない
      insert(:skill_class_score_log,
        user: user,
        skill_class: skill_class,
        percentage: 30.0,
        date: ~D[2023-10-25]
      )

      # 20.0は直近として最後に付加される（ただしnil分がその後ろにつく）
      expected_progress =
        @nil_25
        |> List.replace_at(1 - 1, 10.0)
        |> List.replace_at(-1 - 5, 20.0)

      with_mocks([date_mock()]) do
        {:ok, show_live, _html} = live(conn, ~p"/graphs/#{skill_panel}")
        data = Map.merge(@base_data_on_now, %{progress: expected_progress}) |> Jason.encode!()
        assert has_element?(show_live, ~s(#growth-graph[data-data='#{data}']))
      end
    end
  end
end
