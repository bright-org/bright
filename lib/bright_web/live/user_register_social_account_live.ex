defmodule BrightWeb.UserRegisterSocialAccountLive do
  @moduledoc """
  OAuth 認証でユーザー登録
  """

  use BrightWeb, :live_view
  alias BrightWeb.UserAuthComponents
  alias Bright.Accounts
  alias Bright.Accounts.User
  alias Bright.Accounts.SocialIdentifierToken

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <UserAuthComponents.header>ユーザー新規作成</UserAuthComponents.header>

    <UserAuthComponents.auth_form
      for={@form}
      id="registration_by_social_auth_form"
      phx-submit="save"
      phx-change="validate"
    >
      <UserAuthComponents.form_section variant="center-w-full">
        <UserAuthComponents.input_with_label field={@form[:name]} id="handle_name" type="text" label_text="ハンドルネーム" variant="w-full" required/>

        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" variant="w-full" required/>

        <UserAuthComponents.social_auth_banner variant={to_string(@provider)} />

        <UserAuthComponents.button variant="mx-auto">ユーザーを新規作成する</UserAuthComponents.button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>

    <UserAuthComponents.link_text href={~p"/users/log_in"}>ログインはこちら</UserAuthComponents.link_text>
    """
  end

  def mount(%{"token" => token} = _params, _session, socket) do
    social_identifier_token = Accounts.get_social_identifier_token(token)

    if social_identifier_token do
      %SocialIdentifierToken{
        name: name,
        email: email,
        identifier: identifier,
        provider: provider
      } = social_identifier_token

      changeset =
        Accounts.change_user_registration_by_social_auth(%User{name: name, email: email})

      socket =
        socket
        |> assign(identifier: identifier, provider: provider)
        |> assign(check_errors: false)
        |> assign_form(changeset)

      {:ok, socket, temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "セッションの期限が切れました。再度やり直してください。")
       |> redirect(to: ~p"/users/log_in")}
    end
  end

  def handle_event(
        "save",
        %{"user" => user_params},
        %{assigns: %{identifier: identifier, provider: provider}} = socket
      ) do
    case Accounts.register_user_by_social_auth(user_params, %{
           identifier: identifier,
           provider: provider
         }) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        {:noreply, socket |> redirect(to: ~p"/users/finish_registration")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration_by_social_auth(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
