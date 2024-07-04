defmodule BrightWeb.DisplayUserHelper do
  @moduledoc """
  Profile取得共通処理
  """
  import Phoenix.Component, only: [assign: 3]
  alias Bright.Accounts
  alias Bright.Repo
  alias Bright.Utils.Aes.Aes128
  alias Bright.Accounts.User
  alias Bright.Teams

  def assign_display_user(%{assigns: %{current_user: current_user}} = socket, %{
        "user_name" => user_name
      }) do
    user =
      Accounts.get_user_by_name!(user_name)
      |> Repo.preload(:user_profile)

    # 面談が確定している、チームに所属している、または支援関係にあるチームに所属している人以外を指定した場合はBright.Exceptions.ForbiddenResourceErrorで404を表示する
    Teams.joined_teams_or_supportee_teams_or_supporter_teams_or_hr_by_user_id!(
      current_user.id,
      user.id
    )

    socket
    |> assign(:me, false)
    |> assign(:anonymous, false)
    |> assign(:display_user, user)
  end

  def assign_display_user(socket, %{"user_name_encrypted" => user_name_encrypted}) do
    user =
      decrypt_user_name(user_name_encrypted)
      |> Accounts.get_user_by_name!()

    display_user =
      %User{}
      |> Map.put(:user_profile, %Bright.UserProfiles.UserProfile{})
      |> Map.put(:id, user.id)
      |> Map.put(:name_encrypted, user_name_encrypted)

    socket
    |> assign(:me, false)
    |> assign(:anonymous, true)
    |> assign(:display_user, display_user)
  end

  def assign_display_user(socket, _params) do
    socket
    |> assign(:me, true)
    |> assign(:anonymous, false)
    |> assign(:display_user, socket.assigns.current_user)
  end

  def encrypt_user_name(%User{} = user) do
    date_time = user.inserted_at |> NaiveDateTime.to_string()
    Aes128.encrypt("#{user.name},#{date_time}")
  end

  def decrypt_user_name(ciphertext) do
    try do
      Aes128.decrypt(ciphertext)
      |> String.split(",")
      |> List.first()
    rescue
      # 復号出来ない場合はDecryptUserNameErrorにする
      exception ->
        reraise(Bright.Exceptions.DecryptUserNameError, [exception: exception], __STACKTRACE__)
    end
  end

  @doc """
  nameあるいはencrypted_nameからuserとanonymousかどうかを返す
  """
  def get_user_from_name_or_name_encrypted(name, name_encrypted)
      when is_nil(name_encrypted) or name_encrypted == "" do
    user = Bright.Accounts.get_user_by_name(name)
    {user, false}
  end

  def get_user_from_name_or_name_encrypted(_name, name_encrypted) do
    user_name = decrypt_user_name(name_encrypted)
    user = Bright.Accounts.get_user_by_name(user_name)
    {user, true}
  end
end
