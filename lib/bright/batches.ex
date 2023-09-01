defmodule Bright.Batches do
  @moduledoc """
  バッチ処理をコマンドラインで実行するためのインターフェースを提供するモジュール。
  """
  @app :bright

  def update_skill_panels do
    load_app()
    Bright.Batches.UpdateSkillPanels.call(jst_today())
  end

  defp load_app do
    Application.load(@app)
  end

  # NOTE: 日本時間の深夜に実行されるバッチを考慮し、日付がずれないようにJSTで実行日を取得する
  defp jst_today do
    DateTime.now!("Asia/Tokyo")
    |> DateTime.to_date()
  end
end
