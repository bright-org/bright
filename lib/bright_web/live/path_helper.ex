defmodule BrightWeb.PathHelper do
  @moduledoc """
  URL構築用の補助モジュール
  """

  import BrightWeb.DisplayUserHelper, only: [encrypt_user_name: 1]

  @doc """
  指定条件で /mypage へ遷移するURLを返す
  """
  def mypage_path(user, anonymous)

  def mypage_path(user, true) do
    "/mypage/anon/#{encrypt_user_name(user)}"
  end

  def mypage_path(user, false) do
    "/mypage/#{user.name}"
  end

  @doc """
  指定条件で /graphs, /panels へ遷移するURLを返す
  """
  def skill_panel_path(root, skill_panel, display_user, me, anonymous)

  def skill_panel_path(root, skill_panel, _display_user, true, _anonymous) do
    # 自ユーザー
    "/#{root}/#{skill_panel.id}"
  end

  def skill_panel_path(root, skill_panel, display_user, false, false) do
    # 対象ユーザーかつ匿名ではない
    "/#{root}/#{skill_panel.id}/#{display_user.name}"
  end

  def skill_panel_path(root, skill_panel, display_user, false, true) do
    # 対象ユーザーかつ匿名
    "/#{root}/#{skill_panel.id}/anon/#{display_user.name_encrypted}"
  end
end
