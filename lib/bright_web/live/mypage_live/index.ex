defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  # import BrightWeb.ChartComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]
  alias Bright.Accounts
  alias Bright.Repo
  alias Bright.Utils.Aes.Aes128
  alias Bright.Accounts.User

  @impl true
  def mount(params, _session, socket) do
    socket
    |> assign_display_user(params)
    |> assign(:page_title, "マイページ")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "マイページ")
    |> assign(:mypage, nil)
  end

  # TODO: プロフィール読み込み共通化対象
  def assign_display_user(socket, %{"user_name" => user_name}) do
    # TODO: チームに所属のチェックを実装すること
    user =
      Accounts.get_user_by_name_or_email(user_name)
      |> Repo.preload(:user_profile)

    socket
    |> assign(:is_anonymous, false)
    |> assign(:display_user, user)
  end

  def assign_display_user(socket, %{"user_name_crypted" => user_name_crypted}) do
    user = decrypt_user_name(user_name_crypted)
    |> Accounts.get_user_by_name_or_email()

    display_user = %User{}
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
    date_time = user.inserted_at |> NaiveDateTime.to_string
    Aes128.encrypt("#{user.name},#{date_time}")
  end

  def decrypt_user_name(ciphertext) do
      Aes128.decrypt(ciphertext)
      |> String.split(",")
      |> List.first()
  end
end
