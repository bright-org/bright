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

    <UserAuthComponents.social_auth_banner variant={to_string(@provider)} />

    <UserAuthComponents.auth_form
      for={@form}
      id="registration_by_social_auth_form"
      phx-submit="save"
      phx-change="validate"
    >
      <UserAuthComponents.form_section variant="center-w-full">
        <UserAuthComponents.input_with_label field={@form[:name]} id="handle_name" type="text" label_text="ハンドル名" variant="w-full" required/>

        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" variant="w-full" required/>

        <div class="mx-auto mt-1 max-w-xs w-full">
          <div phx-click="toggre_is_terms_of_service_checked" class="mt-1 w-full">
            <input type="checkbox" id="terms_of_service" class="rounded" checked={@is_terms_of_service_checked?} />
            <label for="terms_of_service" class="pl-1 text-xs">
              <a href="https://bright-fun.org/terms/terms.pdf" class="text-link underline font-semibold" target="_blank">利用規約</a>に同意する
            </label>
          </div>

          <div phx-click="toggre_is_privacy_policy_checked" class="mt-1 w-full">
            <input type="checkbox" id="privacy_policy" class="rounded" checked={@is_privacy_policy_checked?} />
            <label for="privacy_policy" class="pl-1 text-xs">
              <a href="https://bright-fun.org/privacy/privacy.pdf" class="text-link underline font-semibold" target="_blank">プライバシーポリシー</a>に同意する
            </label>
          </div>

          <div phx-click="toggre_is_law_checked" class="mt-1 w-full">
            <input type="checkbox" id="law" class="rounded" checked={@is_law_checked?} />
            <label for="law" class="pl-1 text-xs">
              <a href="https://bright-fun.org/laws/laws.pdf" class="text-link underline font-semibold" target="_blank">法令に基づく表記</a>を確認した
            </label>
          </div>
        </div>

        <UserAuthComponents.button variant="mx-auto" disabled={!(@is_terms_of_service_checked? && @is_privacy_policy_checked? && @is_law_checked?)}>ユーザーを新規作成する</UserAuthComponents.button>
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
        display_name: display_name,
        identifier: identifier,
        provider: provider
      } = social_identifier_token

      changeset =
        Accounts.change_user_registration_by_social_auth(%User{name: name, email: email})

      socket =
        socket
        |> assign(identifier: identifier, provider: provider, display_name: display_name)
        |> assign(check_errors: false)
        |> assign(is_terms_of_service_checked?: false)
        |> assign(is_privacy_policy_checked?: false)
        |> assign(is_law_checked?: false)
        |> assign_form(changeset)

      {:ok, socket, temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "セッションの期限が切れました。再度やり直してください。")
       |> redirect(to: ~p"/users/register")}
    end
  end

  def handle_event(
        "toggre_is_terms_of_service_checked",
        _params,
        %{assigns: %{is_terms_of_service_checked?: is_terms_of_service_checked?}} = socket
      ) do
    socket
    |> assign(is_terms_of_service_checked?: !is_terms_of_service_checked?)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "toggre_is_privacy_policy_checked",
        _params,
        %{assigns: %{is_privacy_policy_checked?: is_privacy_policy_checked?}} = socket
      ) do
    socket
    |> assign(is_privacy_policy_checked?: !is_privacy_policy_checked?)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "toggre_is_law_checked",
        _params,
        %{assigns: %{is_law_checked?: is_law_checked?}} = socket
      ) do
    socket
    |> assign(is_law_checked?: !is_law_checked?)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "save",
        %{"user" => user_params},
        %{assigns: %{identifier: identifier, provider: provider, display_name: display_name}} =
          socket
      ) do
    case Accounts.register_user_by_social_auth(user_params, %{
           identifier: identifier,
           provider: provider,
           display_name: display_name
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
