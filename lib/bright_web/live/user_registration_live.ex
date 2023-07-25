defmodule BrightWeb.UserRegistrationLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias Bright.Accounts.User
  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
    <UserAuthComponents.header>ユーザー新規作成</UserAuthComponents.header>

    <UserAuthComponents.auth_form
      :let={_f}
      for={@form}
      id="registration_form"
      phx-submit="save"
      phx-change="validate"
    >
      <UserAuthComponents.form_section variant="left">
        <UserAuthComponents.social_auth_button variant="google" />
        <UserAuthComponents.social_auth_button variant="github" />
        <UserAuthComponents.social_auth_button variant="facebook" />
        <UserAuthComponents.social_auth_button variant="twitter" />
      </UserAuthComponents.form_section>

      <UserAuthComponents.or_text>または</UserAuthComponents.or_text>

      <UserAuthComponents.form_section variant="right">
        <UserAuthComponents.input_with_label field={@form[:name]} id="handle_name" type="text" label_text="ハンドルネーム" required/>

        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" required/>

        <UserAuthComponents.input_with_label field={@form[:password]} id="password" type="password" label_text="パスワード" required/>

        <UserAuthComponents.button>ユーザーを新規作成する</UserAuthComponents.button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>

    <UserAuthComponents.link_text href={~p"/users/log_in"}>ログインはこちら</UserAuthComponents.link_text>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
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
    changeset = Accounts.change_user_registration(%User{}, user_params)
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
