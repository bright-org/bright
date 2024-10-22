defmodule BrightWeb.TimelineHelperTest do
  use Bright.DataCase, async: false

  import Mock

  alias BrightWeb.TimelineHelper

  defp date_mock do
    {
      Date,
      [:passthrough],
      [
        utc_today: fn -> ~D[2023-10-25] end
      ]
    }
  end

  describe "get_current/0" do
    test "returns current date timeline" do
      with_mocks([date_mock()]) do
        assert %{
                 future_date: ~D[2024-01-01],
                 start_date: ~D[2023-01-01],
                 labels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
                 selected_label: "now",
                 future_enabled: false,
                 past_enabled: true,
                 display_now: true
               } = TimelineHelper.get_current()
      end
    end
  end

  describe "get_by_label/1" do
    test "returns timeline by given label" do
      with_mocks([date_mock()]) do
        assert %{
                 future_date: ~D[2024-01-01],
                 start_date: ~D[2023-01-01],
                 labels: ["2023.1", "2023.4", "2023.7", "2023.10", "2024.1"],
                 selected_label: "2023.10",
                 future_enabled: false,
                 past_enabled: true,
                 display_now: true
               } = TimelineHelper.get_by_label("2023.10")
      end
    end

    test "returns past timeline by given label" do
      with_mocks([date_mock()]) do
        assert %{
                 future_date: ~D[2024-01-01],
                 start_date: ~D[2022-04-01],
                 labels: ["2022.4", "2022.7", "2022.10", "2023.1", "2023.4"],
                 selected_label: "2022.10",
                 future_enabled: true,
                 past_enabled: true,
                 display_now: false
               } = TimelineHelper.get_by_label("2022.10")
      end
    end

    test "returns current timeline if given label is invalid" do
      with_mocks([date_mock()]) do
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("2022.9")
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("2022.x")
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("2022.10.1")
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("202210")
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("dummy")
      end
    end

    test "returns current timeline if given label is older than service start date" do
      with_mocks([date_mock()]) do
        assert %{selected_label: "2021.10"} = TimelineHelper.get_by_label("2021.10")
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("2021.7")
      end
    end

    test "returns current timeline if given label is future" do
      with_mocks([date_mock()]) do
        assert %{selected_label: "2023.10"} = TimelineHelper.get_by_label("2023.10")
        assert %{selected_label: "now"} = TimelineHelper.get_by_label("2024.01")
      end
    end
  end

  describe "get_prev_date_from_now/1" do
    test "returns prev date from now" do
      with_mocks([date_mock()]) do
        timeline = TimelineHelper.get_current()
        assert ~D[2023-10-01] == TimelineHelper.get_prev_date_from_now(timeline)
      end
    end
  end
end
