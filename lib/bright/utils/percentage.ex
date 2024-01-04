defmodule Bright.Utils.Percentage do
  @moduledoc """
  パーセンテージを扱うモジュール
  """

  def calc_percentage(_value, 0), do: 0.0

  def calc_percentage(value, size) do
    100 * (value / size)
  end

  def calc_floor_percentage(value, size) do
    calc_percentage(value, size)
    |> floor()
  end

  def calc_ceil_percentage(value, size) do
    calc_percentage(value, size)
    |> ceil()
  end
end
