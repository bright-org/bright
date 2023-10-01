defmodule Bright.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Bright.Accounts.User2faCodes
  alias Bright.Accounts.SocialIdentifierToken
  alias Bright.Accounts.UserSocialAuth
  alias Bright.Accounts.UserSubEmail
  alias Bright.UserProfiles
  alias Bright.UserJobProfiles
  alias Bright.Repo

  alias Bright.Accounts.{User, UserToken, UserNotifier}
  alias Bright.Onboardings.UserOnboarding
  alias Bright.Utils.GoogleCloud.Storage

  ## Database getters

  @doc """
  Gets a confirmed user by email.

  When `:including_not_confirmed` option is given and true, gets a user including not confirmed.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("foo@example.com", including_not_confirmed: true)
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    User.email_query(email)
    |> Repo.one()
  end

  def get_user_by_email(email, including_not_confirmed: true) when is_binary(email) do
    User.email_query(email, including_not_confirmed: true)
    |> Repo.one()
  end

  @doc """
  Gets a confirmed and password registered user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)

    if User.valid_password?(user, password), do: user
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    user_changeset =
      %User{}
      |> User.registration_changeset(attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, user_changeset)
    |> Ecto.Multi.run(:user_profile, fn _repo, %{user: user} ->
      UserProfiles.create_initial_user_profile(user.id)
    end)
    |> Ecto.Multi.run(:user_job_profile, fn _repo, %{user: user} ->
      UserJobProfiles.create_user_job_profile(%{user_id: user.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs,
      validate_name: false,
      hash_password: false,
      validate_email: false
    )
  end

  ## User registration by social auth

  @doc """
  Register user by social auth.
  """
  def register_user_by_social_auth(user_params, user_social_auth_params) do
    user_changeset =
      %User{}
      |> User.registration_by_social_auth_changeset(user_params)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, user_changeset)
    |> Ecto.Multi.run(:user_social_auth, fn repo, %{user: user} ->
      user_social_auth_params =
        user_social_auth_params
        |> Map.merge(%{user_id: user.id})

      {:ok,
       %UserSocialAuth{}
       |> UserSocialAuth.change_user_social_auth(user_social_auth_params)
       |> repo.insert!()}
    end)
    |> Ecto.Multi.run(:user_profile, fn _repo, %{user: user} ->
      UserProfiles.create_initial_user_profile(user.id)
    end)
    |> Ecto.Multi.run(:user_job_profile, fn _repo, %{user: user} ->
      UserJobProfiles.create_user_job_profile(%{user_id: user.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for user registration by social auth (OAuth).

  ## Examples

      iex> change_user_registration_by_social_auth(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration_by_social_auth(%User{} = user, attrs \\ %{}) do
    User.registration_by_social_auth_changeset(user, attrs,
      validate_name: false,
      hash_password: false,
      validate_email: false,
      validate_password_registered: false,
      generate_dummy_password: false
    )
  end

  @doc """
  Gets user by provider and identifier

  ## Examples

      iex> get_user_by_provider_and_identifier(:google, "1")
      %User{}

  """
  def get_user_by_provider_and_identifier(provider, identifier) do
    UserSocialAuth.user_by_provider_and_identifier_query(provider, identifier)
    |> Repo.one()
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc ~S"""
  Delivers the add email instructions to the given user.

  ## Examples

      iex> deliver_user_add_sub_email_instructions(user, new_sub_email, &url(~p"/users/confirm_sub_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_add_sub_email_instructions(%User{} = user, new_sub_email, add_email_url_fun)
      when is_function(add_email_url_fun, 1) do
    {encoded_token, user_token} =
      UserToken.build_email_token(user, "confirm_sub_email", new_sub_email)

    Repo.insert!(user_token)

    UserNotifier.deliver_add_sub_email_instructions(
      user,
      new_sub_email,
      add_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password before submit.
  It validates current password.

  ## Examples

      iex> change_user_password_before_submit(user, "xxx", %{})
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password_before_submit(user, password, attrs \\ %{}) do
    user
    |> User.password_changeset(attrs, hash_password: false)
    |> User.validate_current_password(password)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for adding the new user sub email.

  ## Examples

      iex> change_new_user_sub_email(user)
      %Ecto.Changeset{data: %UserSubEmail{}}

  """
  def change_new_user_sub_email(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:user_sub_emails)
    |> UserSubEmail.changeset(attrs, validate_sub_email_count: false, validate_email: false)
  end

  @doc """
  Emulates that the sub_email will add without actually changing
  it in the database.

  ## Examples

      iex> apply_new_user_sub_email(user, %{email: ...})
      {:ok, %UserSubEmail{}}

      iex> apply_new_user_sub_email(user, %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_new_user_sub_email(user, attrs) do
    user
    |> Ecto.build_assoc(:user_sub_emails)
    |> UserSubEmail.changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Adds the user sub email using the given token.

  If the token matches, the user email is added and the token is deleted.
  """
  def add_user_sub_email(user, token) do
    context = "confirm_sub_email"

    with {:ok, query} <-
           UserToken.verify_confirm_sub_email_token_query(token, context),
         %UserToken{sent_to: email, token: token} <- Repo.one(query),
         {:ok, _} <-
           Repo.transaction(user_add_sub_email_multi(user, email, context, token)) do
      :ok
    else
      {:error, :user_sub_email,
       %Ecto.Changeset{errors: [email: {"already has max number of sub emails", []}]}, _} ->
        :already_has_max_number_of_sub_emails

      _ ->
        :error
    end
  end

  defp user_add_sub_email_multi(user, email, context, token) do
    changeset =
      user
      |> Ecto.build_assoc(:user_sub_emails)
      |> UserSubEmail.changeset(%{email: email})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user_sub_email, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.token_and_context_query(token, context))
  end

  @doc """
  Delete user sub email.

  NOTE:
  `user_sub_email` has uniqueness in email.
  Nevertheless, you need `user` to avoid deleting other user's sub email
  """
  def delete_user_sub_email(user, sub_email) do
    user
    |> UserSubEmail.user_and_email_query(sub_email)
    |> Repo.delete_all()

    :ok
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      {:ok, _} = create_confirm_token(user, user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  # NOTE: すでにある場合は削除する
  defp create_confirm_token(user, user_token) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
    |> Ecto.Multi.insert(:insert_user_token, user_token)
    |> Repo.transaction()
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Two factor auth
  @doc """
  Setup user two factor auth.

  1. Delete existing token and Generate user two factor auth session token
  2. Delete existing code and Generate user two factor auth code
  3. Deliver two factor auth code to user

  ## Examples

      iex> setup_user_2fa_auth(user)
      "token"

  """
  def setup_user_2fa_auth(user) do
    {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_token,
      UserToken.user_and_contexts_query(user, ["two_factor_auth_session"])
    )
    |> Ecto.Multi.insert(:user_token, user_token)
    |> Ecto.Multi.delete_all(
      :delete_2fa_code,
      User2faCodes.user_query(user)
    )
    |> Ecto.Multi.insert(:user_2fa_code, User2faCodes.build_by_user(user))
    |> Ecto.Multi.run(:deliver_2fa_auth_code, fn _repo, %{user_2fa_code: user_2fa_code} ->
      UserNotifier.deliver_2fa_instructions(user, user_2fa_code.code)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> token
    end
  end

  @doc """
  Gets the user by two factor auth session token.

  ## Examples

      iex> get_user_by_2fa_auth_session_token("validtoken")
      %User{}

      iex> get_user_by_2fa_auth_session_token("invalidtoken")
      nil

  """
  def get_user_by_2fa_auth_session_token(token) do
    with {:ok, query} <-
           UserToken.verify_two_factor_auth_token_query(token, "two_factor_auth_session"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Finish user two factor auth and return two_factor_auth_done token.

  1. Delete existing two_factor_auth_session, two_factor_auth_done tokens, user_2fa_code.
  2. Generate two_factor_auth_done token.

  ## Examples

      iex> finish_user_2fa(user)
      "token"

  """
  def finish_user_2fa(user) do
    {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_done")

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_token,
      UserToken.user_and_contexts_query(user, ["two_factor_auth_session", "two_factor_auth_done"])
    )
    |> Ecto.Multi.delete_all(
      :delete_2fa_code,
      User2faCodes.user_query(user)
    )
    |> Ecto.Multi.insert(:user_token, user_token)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> token
    end
  end

  def get_user_by_2fa_done_token(token) do
    with {:ok, query} <-
           UserToken.verify_two_factor_auth_token_query(token, "two_factor_auth_done"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Verify user two factor auth code and return true or false.
  """
  def user_2fa_code_valid?(user, code) do
    User2faCodes.verify_user_2fa_code_query(user, code)
    |> Repo.exists?()
  end

  @doc """
  Generate social indentifier token.

  ## Examples

      iex> generate_social_identifier_token(%{name: "koyo", email: "dummy@example.com", provider: :google, identifier: "1})
      "token"

  """
  def generate_social_identifier_token(
        %{
          name: _name,
          email: _email,
          display_name: _display_name,
          provider: provider,
          identifier: identifier
        } = social_identifier_attrs
      ) do
    {token, social_identifier_token} = SocialIdentifierToken.build_token(social_identifier_attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_token,
      SocialIdentifierToken.provider_and_identifier_query(provider, identifier)
    )
    |> Ecto.Multi.insert(:insert_token, social_identifier_token)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> token
    end
  end

  @doc """
  Gets social identifier token.

  ## Examples

      iex> get_social_identifier_token("valid token")
      %SocialIdentifierToken{}

      iex> get_social_identifier_token("invalid token")
      nil

  """
  def get_social_identifier_token(token) do
    with {:ok, query} <-
           SocialIdentifierToken.verify_token_query(token),
         %SocialIdentifierToken{} = social_identifier_token <- Repo.one(query) do
      social_identifier_token
    else
      _ -> nil
    end
  end

  @doc """
  Link a social account to a user.

  ## Examples

      iex> link_social_account(user, attrs)
      {:ok, %UserSocialAuth{}}

      iex> link_social_account(user, attrs)
      {:error, changeset}

  """
  def link_social_account(user, attrs) do
    attrs
    |> Map.merge(%{user_id: user.id})
    |> then(&UserSocialAuth.change_user_social_auth(%UserSocialAuth{}, &1))
    |> Repo.insert()
  end

  @doc """
  Unlink a social account to a user.

  It cannot unlink when user has not registered a password true and no other user_social_account exists to avoid user cannot login anymore.

  ## Examples

      iex> unlink_social_account(user, provider)
      :ok

      iex> unlink_social_account(user, provider)
      :cannot_unlink_last_one

  """
  def unlink_social_account(user, provider) do
    case can_unlink_social_account?(user, provider) do
      true ->
        UserSocialAuth.user_id_and_provider_query(user.id, provider)
        |> Repo.delete_all()

      false ->
        :cannot_unlink_last_one
    end
  end

  # 連携解除したことでログイン不可能にならないようにチェックする
  # 独自 ID 登録ユーザーの場合は連携解除可能
  defp can_unlink_social_account?(%User{password_registered: true}, _provider), do: true
  # SNS ID 登録ユーザーの場合は他にも SNS 連携していれば削除可能
  defp can_unlink_social_account?(%User{password_registered: false} = user, provider) do
    UserSocialAuth.user_other_provider_query(user.id, provider)
    |> Repo.exists?()
  end

  @doc """
  Returns changeset for changing a user and a user_profile
  """
  def change_user_with_user_profile(%User{} = user, attrs \\ %{}) do
    User.user_with_profile_changeset(user, attrs, validate_name: false)
  end

  @doc """
  Updates a user and a user_profile.

  ## Examples

      # Without uploading file.
      iex> update_user_with_user_profile(user, %{field: new_value}, nil)
      {:ok, %User{}}

      # With Uploading file.
      iex> update_user_with_user_profile(user, %{field: new_value}, "/tmp/xxx.png")
      {:ok, %User{}}

      iex> update_user_with_user_profile(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_with_user_profile(%User{} = user, attrs, nil) do
    user
    |> User.user_with_profile_changeset(attrs)
    |> Repo.update()
  end

  def update_user_with_user_profile(
        %User{} = user,
        %{"user_profile" => %{"icon_file_path" => storage_path}} = attrs,
        local_icon_file_path
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.user_with_profile_changeset(user, attrs))
    |> Ecto.Multi.run(:upload_gcs, fn _repo, %{user: _user} ->
      :ok = Storage.upload!(local_icon_file_path, storage_path)

      {:ok, :uploaded}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  get user by name or email full match

  ## Examples

      iex> get_user_by_name_or_email("name or email full match")
      {:ok, %User{}}

      iex> get_user_by_name_or_email("not full match")
      nil

  """
  def get_user_by_name_or_email(name_or_email) do
    from(u in User,
      where:
        (u.name == ^name_or_email or u.email == ^name_or_email) and not is_nil(u.confirmed_at)
    )
    |> preload(:user_profile)
    |> Repo.one()
  end

  def get_user_by_name(name) do
    User
    |> where([user], not is_nil(user.confirmed_at))
    |> where([user], user.name == ^name)
    |> Repo.one()
  end

  def get_user_by_name!(name) do
    User
    |> where([user], not is_nil(user.confirmed_at))
    |> where([user], user.name == ^name)
    |> Repo.one!()
  end

  @doc """
  Check if onboarding is already finished.

  ## Examples

      iex> onboarding_finished?(user)
      true

      iex> onboarding_finished?(user)
      false

  """
  def onboarding_finished?(user) do
    from(user_onboarding in UserOnboarding, where: user_onboarding.user_id == ^user.id)
    |> Repo.exists?()
  end

  def list_users_without_current_user_dev(user_id) do
    User
    |> where([user], not (user.id == ^user_id))
    |> preload(:skill_panels)
    |> Repo.all()
  end
end
