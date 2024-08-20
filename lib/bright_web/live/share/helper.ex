defmodule BrightWeb.Share.Helper do
  @moduledoc """
  シェア画面の共通処理
  """

  use BrightWeb, :verified_routes
  import Phoenix.Component, only: [assign: 3]

  alias Bright.Share.Token
  alias Bright.Utils.GoogleCloud.Storage
  alias Bright.Accounts.User

  @doc """
  socket に assign されている current_user と skill_ckass から share_graph_url を assign する。
  share_graph_url には、share_graph_token が付与されている。
  この share_graph_token は画面名が入っているため、悪意あるユーザーが他の画面で用いても復号できないようにしている。
  """
  def assign_share_graph_url(
        %{assigns: %{current_user: current_user, skill_class: skill_class}} = socket
      ) do
    encoded_share_graph_token = Token.encode_share_graph_token(current_user.id, skill_class.id)
    share_graph_url = gen_share_graph_url(encoded_share_graph_token)

    socket
    |> assign(:share_graph_url, share_graph_url)
    |> assign(:encode_share_graph_token, encoded_share_graph_token)
  end

  @doc """
  share_graph_urlを生成する
  """
  def gen_share_graph_url(token) do
    url(~p"/share/#{token}/graphs")
  end

  def gen_share_graph_url(%User{} = user, skill_class) do
    url(~p"/share/#{Token.encode_share_graph_token(user.id, skill_class.id)}/graphs")
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
    ogp_path = "ogp/#{share_graph_token}.png"
    og_image = Storage.public_url("ogp/#{share_graph_token}.png")

    og_image =
      Storage.get(ogp_path)
      |> get_og_image(og_image)

    assign(socket, :og_image, og_image)
  end

  defp get_og_image({:ok, _}, og_image), do: og_image
  defp get_og_image({:error, _}, _og_image), do: "https://bright-fun.org/images/ogp_a.png"
end
