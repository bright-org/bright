defmodule Bright.Utils.PercentageTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  alias Bright.Utils.Percentage

  describe "calc_percentage/2" do
    test_with_params "returns calculated value",
                     fn value, size, expected ->
                       assert expected == Float.round(Percentage.calc_percentage(value, size), 2)
                     end do
      [
        {1, 1, 100.0},
        {1, 2, 50.0},
        {1, 3, 33.33},
        {2, 3, 66.67},
        "case divided by 0": {1, 0, 0}
      ]
    end
  end

  describe "calc_floor_percentage/2" do
    test_with_params "returns calculated value",
                     fn value, size, expected ->
                       assert expected == Percentage.calc_floor_percentage(value, size)
                     end do
      [
        {1, 1, 100},
        {1, 2, 50},
        {1, 3, 33},
        {2, 3, 66},
        "case divided by 0": {1, 0, 0}
      ]
    end
  end

  describe "calc_ceil_percentage/2" do
    test_with_params "returns calculated value",
                     fn value, size, expected ->
                       assert expected == Percentage.calc_ceil_percentage(value, size)
                     end do
      [
        {1, 1, 100},
        {1, 2, 50},
        {1, 3, 34},
        {2, 3, 67},
        "case divided by 0": {1, 0, 0}
      ]
    end
  end
end
