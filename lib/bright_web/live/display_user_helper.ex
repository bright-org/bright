defmodule BrightWeb.DisplayUserHelper do
  @moduledoc """
  Profile取得共通処理
  """
  import Phoenix.Component, only: [assign: 3]
  alias Bright.Accounts
  alias Bright.Repo
  alias Bright.Utils.Aes.Aes128
  alias Bright.Accounts.User

  # TODO: プロフィール読み込み共通化対象
  def assign_display_user(socket, %{"user_name" => user_name}) do
    # TODO: チームに所属のチェックを実装すること
    user =
      Accounts.get_user_by_name(user_name)
      |> Repo.preload(:user_profile)

    socket
    |> assign(:is_anonymous, false)
    |> assign(:display_user, user)
  end

  def assign_display_user(socket, %{"user_name_crypted" => user_name_crypted}) do
    user =
      decrypt_user_name(user_name_crypted)
      |> Accounts.get_user_by_name()

    display_user =
      %User{}
      |> Map.put(:user_profile, %Bright.UserProfiles.UserProfile{})
      |> Map.put(:id, user.id)

    socket
    |> assign(:is_anonymous, true)
    |> assign(:display_user, display_user)
  end

  def assign_display_user(socket, _params) do
    socket
    |> assign(:is_anonymous, false)
    |> assign(:display_user, socket.assigns.current_user)
  end

  def encrypt_user_name(%User{} = user) do
    date_time = user.inserted_at |> NaiveDateTime.to_string()
    Aes128.encrypt("#{user.name},#{date_time}")
  end

  def decrypt_user_name(ciphertext) do
    Aes128.decrypt(ciphertext)
    |> String.split(",")
    |> List.first()
  end
end
