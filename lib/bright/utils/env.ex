defmodule Bright.Utils.Env do
  @moduledoc """
  実行環境に関する値を取得するためのユーティリティ。
  """

  @doc """
  prod環境で実行されていればtrue、それ以外の環境で実行されていればfalseを返す。
  """
  def prod? do
    System.get_env("BRIGHT_ENV") == "prod"
  end

  def stg? do
    System.get_env("BRIGHT_ENV") == "stg"
  end

  def dev? do
    System.get_env("BRIGHT_ENV") == "dev"
  end
end
