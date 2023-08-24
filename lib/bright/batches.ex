defmodule Bright.Batches do
  @moduledoc """
  バッチ処理をコマンドラインで実行するためのインターフェースを提供するモジュール。
  """
  @app :bright

  def update_skill_panels do
    load_app()
    Bright.Batches.UpdateSkillPanels.call()
  end

  defp load_app do
    Application.load(@app)
  end
end
