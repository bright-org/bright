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
        <UserAuthComponents.social_auth_button href={~p"/auth/google"} variant="google">Google</UserAuthComponents.social_auth_button>
        <UserAuthComponents.social_auth_button href="#" variant="github">GitHub</UserAuthComponents.social_auth_button>
        <UserAuthComponents.social_auth_button href="#" variant="facebook">Facebook</UserAuthComponents.social_auth_button>
        <UserAuthComponents.social_auth_button href="#" variant="twitter">Twitter</UserAuthComponents.social_auth_button>
      </UserAuthComponents.form_section>

      <UserAuthComponents.or_text>または</UserAuthComponents.or_text>

      <UserAuthComponents.form_section variant="right">
        <UserAuthComponents.input_with_label field={@form[:name]} id="handle_name" type="text" label_text="ハンドル名" required/>

        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" required/>

        <UserAuthComponents.input_with_label field={@form[:password]} id="password" type="password" label_text="パスワード" required/>

        <div phx-click="toggre_is_terms_of_service_checked" class="mt-1">
          <input type="checkbox" id="terms_of_service" class="rounded" checked={@is_terms_of_service_checked?} />
          <label for="terms_of_service" class="pl-1 text-xs">
            <a href="https://bright-fun.org/terms/terms.pdf" class="text-link underline font-semibold" target="_blank">利用規約</a>に同意する
          </label>
        </div>

        <div phx-click="toggre_is_privacy_policy_checked" class="mt-1">
          <input type="checkbox" id="privacy_policy" class="rounded" checked={@is_privacy_policy_checked?} />
          <label for="privacy_policy" class="pl-1 text-xs">
            <a href="https://bright-fun.org/privacy/privacy.pdf" class="text-link underline font-semibold" target="_blank">プライバシーポリシー</a>に同意する
          </label>
        </div>

        <div phx-click="toggre_is_law_checked" class="mt-1">
          <input type="checkbox" id="law" class="rounded" checked={@is_law_checked?} />
          <label for="law" class="pl-1 text-xs">
            <a href="https://bright-fun.org/laws/laws.pdf" class="text-link underline font-semibold" target="_blank">法令に基づく表記</a>を確認した
          </label>
        </div>

        <UserAuthComponents.button variant="mt-sm" disabled={!(@is_terms_of_service_checked? && @is_privacy_policy_checked? && @is_law_checked?)}>ユーザーを新規作成する</UserAuthComponents.button>
        <UserAuthComponents.link_text href={~p"/users/log_in"}>ログインはこちら</UserAuthComponents.link_text>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>

    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(check_errors: false)
      |> assign(is_terms_of_service_checked?: false)
      |> assign(is_privacy_policy_checked?: false)
      |> assign(is_law_checked?: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
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
