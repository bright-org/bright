defmodule BrightWeb.Share.HelperTest do
  use BrightWeb.ConnCase

  alias Bright.Share.Token
  alias BrightWeb.Share.Helper

  describe "assign_share_graph_url/1" do
    test "assigns share_graph_url" do
      user = insert(:user)
      skill_class = insert(:skill_class_with_skill_panel)

      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(:current_user, user)
        |> Phoenix.Component.assign(:skill_class, skill_class)
        |> Helper.assign_share_graph_url()

      assert socket.assigns.share_graph_url =~ ~r"/share/.*/graphs"
    end
  end

  describe "decode_share_graph_token!/1" do
    test "assigns from params" do
      %{
        user: user,
        skill_class_1: skill_class
      } = create_user_with_skill()

      %{user_id: user_id, skill_class_id: skill_class_id} =
        Helper.decode_share_graph_token!(%{
          "share_graph_token" => Token.encode_share_graph_token(user.id, skill_class.id)
        })

      assert user_id == user.id
      assert skill_class_id == skill_class.id
    end

    test "raise Bright.Exceptions.DecryptShareGraphTokenError when cannot decode" do
      assert_raise Bright.Exceptions.DecryptShareGraphTokenError,
                   "Decrypt share graph token error",
                   fn ->
                     Helper.decode_share_graph_token!(%{
                       "share_graph_token" => "invalid"
                     })
                   end
    end
  end
end
