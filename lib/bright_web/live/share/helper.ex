defmodule BrightWeb.Share.Helper do
  @moduledoc """
  シェア画面の共通処理
  """

  use BrightWeb, :verified_routes
  import Phoenix.Component, only: [assign: 3]
  alias Bright.Share.Token

  @doc """
  socket に assign されている current_user と skill_ckass から share_graph_url を assign する。
  share_graph_url には、share_graph_token が付与されている。
  この share_graph_token は画面名が入っているため、悪意あるユーザーが他の画面で用いても復号できないようにしている。
  """
  def assign_share_graph_url(
        %{assigns: %{current_user: current_user, skill_class: skill_class}} = socket
      ) do
    encode_share_graph_token = Token.encode_share_graph_token(current_user.id, skill_class.id)

    assign(
      socket,
      :share_graph_url,
      url(~p"/share/#{encode_share_graph_token}/graphs")
    )
    |> assign(:encode_share_graph_token, encode_share_graph_token)
  end

  @doc """
  params に含まれる share_graph_token を復号して user_id と skill_class_id を取得する。
  なお他の画面で使った場合はエラーになるように page_key を復号時にチェックしている。


  ## Examples
      iex> decode_share_graph_token!(%{"share_graph_token" => "encrypted"})
      %{user_id: "xxxx", skill_class_id: "xxxx"}
  """
  def decode_share_graph_token!(
        %{
          "share_graph_token" => share_graph_token
        } = _params
      ) do
    [user_id, skill_class_id] = Token.decode_share_graph_token!(share_graph_token)

    %{
      user_id: user_id,
      skill_class_id: skill_class_id
    }
  end

  def assign_share_graph_og_image(
        socket,
        %{
          "share_graph_token" => share_graph_token
        } = _params
      ) do
    assign(socket, :og_image, "#{share_graph_token}.pnd")
  end
end
