defmodule BrightWeb.Share.Token do
  @moduledoc """
  シェア画面用のトークン関連処理
  """

  alias Bright.Utils.Aes.Aes128

  @page_key %{
    share_graph: "share_graph"
  }

  @doc """
  user_id と skill_class_id から share_graph_token を生成する。
  token には page_key を付与しているため、他の画面で復号した場合はエラーになるように設計している。
  """
  def encode_share_graph_token(user_id, skill_class_id) do
    Aes128.encrypt("#{user_id},#{skill_class_id},#{@page_key[:share_graph]}")
  end

  @doc """
  share_graph_token を復号して user_id と skill_class_id を取得する。
  なお他の画面で使った場合はエラーになるように page_key を復号時にチェックしている。
  """
  def decode_share_graph_token!(share_graph_token) do
    page_key = @page_key[:share_graph]

    try do
      [user_id, skill_class_id, ^page_key] =
        Aes128.decrypt(share_graph_token)
        |> String.split(",")

      [user_id, skill_class_id]
    rescue
      exception ->
        reraise(
          Bright.Exceptions.DecryptShareGraphTokenError,
          [exception: exception],
          __STACKTRACE__
        )
    end
  end
end
