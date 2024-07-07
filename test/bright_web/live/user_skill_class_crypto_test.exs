defmodule BrightWeb.UserSkillClassCryptoTest do
  use BrightWeb.ConnCase

  alias BrightWeb.UserSkillClassCrypto
  alias Bright.Utils.Aes.Aes128

  describe "assign_share_graph_url/1" do
    test "assigns share_graph_url" do
      user = insert(:user)
      skill_class = insert(:skill_class_with_skill_panel)

      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(:current_user, user)
        |> Phoenix.Component.assign(:skill_class, skill_class)
        |> UserSkillClassCrypto.assign_share_graph_url()

      assert socket.assigns.share_graph_url =~ ~r"/share/.*/graphs"
    end
  end

  describe "assign_from_encrypted_user_id_and_skill_class_id/2" do
    test "assigns from params" do
      %{
        user: user,
        skill_panel: skill_panel,
        skill_class: skill_class,
        skill_class_score: skill_class_score
      } = create_user_with_skill()

      socket =
        %Phoenix.LiveView.Socket{}
        |> UserSkillClassCrypto.assign_from_encrypted_user_id_and_skill_class_id(%{
          "encrypted_user_id_and_skill_class_id" => Aes128.encrypt("#{user.id},#{skill_class.id}")
        })

      assert socket.assigns.me == false
      assert socket.assigns.anonymous == true
      assert socket.assigns.display_user.id == user.id
      assert socket.assigns.skill_panel.id == skill_panel.id
      assert socket.assigns.skill_class.id == skill_class.id
      assert socket.assigns.skill_class_score.id == skill_class_score.id
    end

    test "raise Bright.Exceptions.DecryptUserAndSkillClassIdError when cannot decode" do
      assert_raise Bright.Exceptions.DecryptUserAndSkillClassIdError,
                   "Decrypt user and skill_class id error",
                   fn ->
                     %Phoenix.LiveView.Socket{}
                     |> UserSkillClassCrypto.assign_from_encrypted_user_id_and_skill_class_id(%{
                       "encrypted_user_id_and_skill_class_id" => "invalid"
                     })
                   end
    end
  end
end
