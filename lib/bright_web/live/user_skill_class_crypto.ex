defmodule BrightWeb.UserSkillClassCrypto do
  @moduledoc """
  ユーザーとスキルクラスの暗号化処理
  """

  use BrightWeb, :verified_routes
  import Phoenix.Component, only: [assign: 3]
  alias Bright.Utils.Aes.Aes128
  alias Bright.SkillPanels
  alias Bright.Accounts
  alias Bright.Repo

  @doc """
  share_graph_url を assign する
  """
  def assign_share_graph_url(socket) do
    assign(
      socket,
      :share_graph_url,
      url(
        ~p"/share/#{encrypt_user_and_skill_class_id(socket.assigns.current_user.id, socket.assigns.skill_class.id)}/graphs"
      )
    )
  end

  @doc """
  暗号化パラメータから assign する
  """
  def assign_from_encrypted_user_id_and_skill_class_id(socket, %{
        "encrypted_user_id_and_skill_class_id" => encrypted_user_id_and_skill_class_id
      }) do
    [user_id, skill_class_id] =
      decrypt_user_and_skill_class_id(encrypted_user_id_and_skill_class_id)

    display_user = Accounts.get_user!(user_id)

    skill_class =
      SkillPanels.get_skill_class!(skill_class_id)
      |> Repo.preload(skill_class_scores: Ecto.assoc(display_user, :skill_class_scores))
      |> Repo.preload(:skill_panel)

    skill_panel = skill_class.skill_panel
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:me, false)
    |> assign(:anonymous, true)
    |> assign(:display_user, display_user)
    |> assign(:skill_panel, skill_panel)
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end

  defp encrypt_user_and_skill_class_id(user_id, skill_class_id) do
    Aes128.encrypt("#{user_id},#{skill_class_id}")
  end

  defp decrypt_user_and_skill_class_id(ciphertext) do
    try do
      Aes128.decrypt(ciphertext)
      |> String.split(",")
    rescue
      exception ->
        reraise(
          Bright.Exceptions.DecryptUserAndSkillClassIdError,
          [exception: exception],
          __STACKTRACE__
        )
    end
  end
end
