defmodule Bright.Batches do
  @moduledoc """
  バッチ処理をコマンドラインで実行するためのインターフェースを提供するモジュール。
  """
  @app :bright

  @doc """
  スキルパネル更新バッチを実行する。

  実行日がJSTで 1/1, 4/1, 7/1, 10/1 のいずれかの場合のみデータが更新され、それ以外の日は dry-run となる。
  """
  def update_skill_panels do
    load_app()

    today = jst_today()
    {_year, month, day} = Date.to_erl(today)
    dry_run = !(day === 1 && Enum.member?([1, 4, 7, 10], month))
    Bright.Batches.UpdateSkillPanels.call(today, dry_run)
  end

  defp load_app do
    Application.load(@app)
    Application.ensure_all_started(@app)
  end

  # NOTE: 日本時間の深夜に実行されるバッチを考慮し、日付がずれないようにJSTで実行日を取得する
  defp jst_today do
    DateTime.now!("Asia/Tokyo")
    |> DateTime.to_date()
  end
end
