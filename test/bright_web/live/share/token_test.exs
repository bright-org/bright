defmodule BrightWeb.Share.TokenTest do
  use BrightWeb.ConnCase

  alias BrightWeb.Share.Token
  alias Bright.Utils.Aes.Aes128

  describe "encode_share_graph_token/2" do
    test "encodes share_graph_token" do
      user = insert(:user)
      skill_class = insert(:skill_class_with_skill_panel)

      share_graph_token = Token.encode_share_graph_token(user.id, skill_class.id)

      assert share_graph_token =~ ~r".*"
    end
  end

  describe "decode_share_graph_token!/1" do
    test "decodes share_graph_token" do
      %{
        user: user,
        skill_class_1: skill_class
      } = create_user_with_skill()

      share_graph_token = Token.encode_share_graph_token(user.id, skill_class.id)

      [user_id, skill_class_id] = Token.decode_share_graph_token!(share_graph_token)

      assert user_id == user.id
      assert skill_class_id == skill_class.id
    end

    test "raise Bright.Exceptions.DecryptShareGraphTokenError when cannot decode" do
      assert_raise Bright.Exceptions.DecryptShareGraphTokenError,
                   "Decrypt share graph token error",
                   fn ->
                     Token.decode_share_graph_token!("invalid")
                   end
    end

    test "raise Bright.Exceptions.DecryptShareGraphTokenError when invalid page_key" do
      %{
        user: user,
        skill_class_1: skill_class
      } = create_user_with_skill()

      assert_raise Bright.Exceptions.DecryptShareGraphTokenError,
                   "Decrypt share graph token error",
                   fn ->
                     Aes128.encrypt("#{user.id},#{skill_class.id},invalid_page_key")
                     |> Token.decode_share_graph_token!()
                   end
    end
  end
end
