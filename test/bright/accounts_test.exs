defmodule Bright.AccountsTest do
  use Bright.DataCase

  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.User2faCodes
  alias Bright.Accounts.SocialIdentifierToken
  alias Bright.UserProfiles.UserProfile
  alias Bright.UserJobProfiles.UserJobProfile

  import Bright.Factory
  import Swoosh.TestAssertions
  alias Bright.Accounts.{User, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "does not return the user if the email exists but confirmed_at is nil" do
      refute Accounts.get_user_by_email("unknown@example.com")
      user = insert(:user_not_confirmed)
      refute Accounts.get_user_by_email(user.email)
    end

    test "returns the user if the email exists" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = insert(:user)
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "does not return the user if the email and password are valid but confirmed_at is nil" do
      user = insert(:user_not_confirmed)

      refute Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end

    test "does not return the user if the email and password are valid but password_registered is false" do
      user = insert(:user_registered_by_social_auth)

      refute Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = insert(:user)

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               name: ["can't be blank"],
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates name and email and password when given" do
      {:error, changeset} =
        Accounts.register_user(%{
          name: String.duplicate("a", 101),
          email: "not valid",
          password: "not valid"
        })

      assert %{
               name: ["should be at most 100 character(s)"],
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.register_user(%{name: too_long, email: too_long, password: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates name uniqueness" do
      %{name: name} = insert(:user)
      {:error, changeset} = Accounts.register_user(%{name: name})
      assert "has already been taken" in errors_on(changeset).name
    end

    test "validates email uniqueness" do
      %{email: email} = insert(:user)
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "user initial data is not created when error" do
      {:error, _changeset} = Accounts.register_user(%{})

      refute Repo.exists?(UserProfile)
    end

    test "registers users with a hashed password and user initial data" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(params_for(:user_before_registration, email: email))
      user_id = user.id

      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)

      assert %UserProfile{
               user_id: ^user_id,
               title: nil,
               detail: nil,
               icon_file_path: nil,
               twitter_url: nil,
               facebook_url: nil,
               github_url: nil
             } = Repo.get_by(UserProfile, user_id: user_id)

      assert %UserJobProfile{
               user_id: ^user_id
             } = Repo.get_by(UserJobProfile, user_id: user_id)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email, :name]
    end

    test "allows fields to be set" do
      name = unique_user_name()
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          params_for(:user_before_registration, name: name, email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :name) == name
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: insert(:user)}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = insert(:user)
      password = valid_user_password()

      {:error, changeset} = Accounts.apply_user_email(user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Repo.get!(User, user.id).email != email
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    setup do
      %{user: insert(:user)}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = insert(:user_not_confirmed)
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: insert(:user)}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: insert(:user)}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: insert(:user).id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    test "sends token through notification" do
      user = insert(:user_not_confirmed)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end

    test "sends token through notification twice and only later token is valid" do
      user = insert(:user_not_confirmed)

      before_token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, before_token} = Base.url_decode64(before_token, padding: false)

      after_token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, after_token} = Base.url_decode64(after_token, padding: false)

      refute Repo.get_by(UserToken, token: :crypto.hash(:sha256, before_token))
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, after_token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end

    test "confirmed user returns :already_confirmed error" do
      user = insert(:user)

      assert {:error, :already_confirmed} =
               Accounts.deliver_user_confirmation_instructions(
                 user,
                 &"/users/confirm/#{&1}"
               )

      refute Repo.exists?(UserToken)
    end
  end

  describe "confirm_user/1" do
    setup do
      user = insert(:user_not_confirmed)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: insert(:user)}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = insert(:user)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: insert(:user)}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "setup_user_2fa_auth/1" do
    test "setup user two factor auth" do
      user = insert(:user)

      Accounts.setup_user_2fa_auth(user)

      assert Repo.get_by!(UserToken, user_id: user.id, context: "two_factor_auth_session")
      assert Repo.aggregate(UserToken, :count) == 1

      user_2fa_code = Repo.get_by!(User2faCodes, user_id: user.id)
      assert user_2fa_code
      assert Repo.aggregate(User2faCodes, :count) == 1

      assert_email_sent(fn email ->
        assert email.subject == "【Bright】二段階認証コード"
        assert email.to == [{"", user.email}]
        assert email.text_body =~ user_2fa_code.code
      end)
    end

    test "deletes existing token and code before setup" do
      user = insert(:user)
      before_user_token = insert(:user_token, user: user, context: "two_factor_auth_session")
      before_user_2fa_code = insert(:user_2fa_code, user: user)

      Accounts.setup_user_2fa_auth(user)

      assert before_user_token !=
               Repo.get_by!(UserToken, user_id: user.id, context: "two_factor_auth_session")

      assert Repo.aggregate(UserToken, :count) == 1

      user_2fa_code = Repo.get_by!(User2faCodes, user_id: user.id)
      assert user_2fa_code != before_user_2fa_code
      assert Repo.aggregate(User2faCodes, :count) == 1

      assert_email_sent(fn email ->
        assert email.subject == "【Bright】二段階認証コード"
        assert email.to == [{"", user.email}]
        assert email.text_body =~ user_2fa_code.code
      end)
    end
  end

  describe "get_user_by_2fa_auth_session_token/1" do
    test "token is valid" do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")
      insert(:user_token, user_token |> Map.from_struct())

      assert user == Accounts.get_user_by_2fa_auth_session_token(token)
    end

    test "token is not exists" do
      refute Accounts.get_user_by_2fa_auth_session_token("not exist token")
    end

    test "token exists but was expired after 1 hours" do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")

      insert(
        :user_token,
        user_token
        |> Map.from_struct()
        |> Map.put(
          :inserted_at,
          NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * 60)
        )
      )

      refute Accounts.get_user_by_2fa_auth_session_token(token)
    end

    test "token exists but is not expired" do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")

      insert(
        :user_token,
        user_token
        |> Map.from_struct()
        |> Map.put(
          :inserted_at,
          NaiveDateTime.utc_now()
          |> NaiveDateTime.add(-1 * 60 * 60)
          |> NaiveDateTime.add(1 * 60)
        )
      )

      assert Accounts.get_user_by_2fa_auth_session_token(token)
    end
  end

  describe "generate_user_2fa_done_token/1" do
    test "generates user two_factor_auth_done token" do
      user = insert(:user)

      Accounts.generate_user_2fa_done_token(user)

      assert Repo.get_by!(UserToken, user_id: user.id, context: "two_factor_auth_done")
    end

    test "deletes existing token before generate" do
      user = insert(:user)
      before_user_token = insert(:user_token, user: user, context: "two_factor_auth_done")

      Accounts.generate_user_2fa_done_token(user)

      assert before_user_token !=
               Repo.get_by!(UserToken, user_id: user.id, context: "two_factor_auth_done")

      assert Repo.aggregate(UserToken, :count) == 1
    end
  end

  describe "get_user_by_2fa_done_token/1" do
    test "token is valid" do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_done")
      insert(:user_token, user_token |> Map.from_struct())

      assert user == Accounts.get_user_by_2fa_done_token(token)
    end

    test "token is not exists" do
      refute Accounts.get_user_by_2fa_done_token("not exist token")
    end

    test "token exists but was expired after 60 days" do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_done")

      insert(
        :user_token,
        user_token
        |> Map.from_struct()
        |> Map.put(
          :inserted_at,
          NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * 60 * 24 * 60)
        )
      )

      refute Accounts.get_user_by_2fa_done_token(token)
    end

    test "token exists and is not expired" do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_done")

      insert(
        :user_token,
        user_token
        |> Map.from_struct()
        |> Map.put(
          :inserted_at,
          NaiveDateTime.utc_now()
          |> NaiveDateTime.add(-1 * 60 * 60 * 24 * 60)
          |> NaiveDateTime.add(1 * 60)
        )
      )

      assert user == Accounts.get_user_by_2fa_done_token(token)
    end
  end

  describe "user_2fa_code_valid?/2" do
    test "code is valid" do
      user_2fa_code = insert(:user_2fa_code)

      assert Accounts.user_2fa_code_valid?(user_2fa_code.user, user_2fa_code.code)
    end

    test "code does not exists" do
      user = insert(:user)

      refute Accounts.user_2fa_code_valid?(user, "012345")
    end

    test "other user code" do
      user = insert(:user)
      user_2fa_code = insert(:user_2fa_code)

      refute Accounts.user_2fa_code_valid?(user, user_2fa_code.code)
    end

    test "code exists but was expired after 10 minutes" do
      user_2fa_code =
        insert(:user_2fa_code,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-10 * 60)
        )

      refute Accounts.user_2fa_code_valid?(user_2fa_code.user, user_2fa_code.code)
    end

    test "code exists and is not expired" do
      user_2fa_code =
        insert(:user_2fa_code,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-9 * 60)
        )

      assert Accounts.user_2fa_code_valid?(user_2fa_code.user, user_2fa_code.code)
    end
  end

  describe "generate_social_identifier_token/1" do
    setup do
      social_identifier_attrs = %{
        name: "koyo",
        email: "dummy@example.com",
        provider: :google,
        identifier: "1"
      }

      %{social_identifier_attrs: social_identifier_attrs}
    end

    test "generates social identifier token", %{social_identifier_attrs: social_identifier_attrs} do
      token = Accounts.generate_social_identifier_token(social_identifier_attrs)

      assert Repo.get_by!(SocialIdentifierToken, name: social_identifier_attrs[:name])
      assert Accounts.get_social_identifier_token(token)
    end

    test "deletes existing token before generate", %{
      social_identifier_attrs: social_identifier_attrs
    } do
      before_token =
        insert(:social_identifier_token_for_google,
          identifier: social_identifier_attrs[:identifier]
        )

      Accounts.generate_social_identifier_token(social_identifier_attrs)

      assert before_token !=
               Repo.get_by!(SocialIdentifierToken, name: social_identifier_attrs[:name])

      assert Repo.aggregate(SocialIdentifierToken, :count) == 1
    end

    test "does not delete other identifier's token", %{
      social_identifier_attrs: social_identifier_attrs
    } do
      insert(:social_identifier_token_for_google, identifier: "10000")

      Accounts.generate_social_identifier_token(social_identifier_attrs)

      assert Repo.aggregate(SocialIdentifierToken, :count) == 2
    end
  end

  describe "get_social_identifier_token/1" do
    setup do
      social_identifier_attrs = %{
        name: "koyo",
        email: "dummy@example.com",
        provider: :google,
        identifier: "1"
      }

      %{social_identifier_attrs: social_identifier_attrs}
    end

    test "token is valid", %{social_identifier_attrs: social_identifier_attrs} do
      {token, social_identifier_token} =
        SocialIdentifierToken.build_token(social_identifier_attrs)

      social_identifier_token =
        insert(:social_identifier_token, social_identifier_token |> Map.from_struct())

      assert Accounts.get_social_identifier_token(token) == social_identifier_token
    end

    test "token is not exists" do
      refute Accounts.get_social_identifier_token("not exist token")
    end

    test "token exists but was expired after 1 hours", %{
      social_identifier_attrs: social_identifier_attrs
    } do
      {token, social_identifier_token} =
        SocialIdentifierToken.build_token(social_identifier_attrs)

      insert(
        :social_identifier_token,
        social_identifier_token
        |> Map.from_struct()
        |> Map.put(
          :inserted_at,
          NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * 60)
        )
      )

      refute Accounts.get_social_identifier_token(token)
    end

    test "token exists and is not expired", %{
      social_identifier_attrs: social_identifier_attrs
    } do
      {token, social_identifier_token} =
        SocialIdentifierToken.build_token(social_identifier_attrs)

      social_identifier_token =
        insert(
          :social_identifier_token,
          social_identifier_token
          |> Map.from_struct()
          |> Map.put(
            :inserted_at,
            NaiveDateTime.utc_now()
            |> NaiveDateTime.add(-1 * 60 * 60)
            |> NaiveDateTime.add(1 * 60)
          )
        )

      assert Accounts.get_social_identifier_token(token) == social_identifier_token
    end
  end

  describe "get_user_by_name_or_email/1" do
    test "only return the user if the name completely match" do
      user = insert(:user)
      refute Accounts.get_user_by_name_or_email(user.name <> "1")
    end

    test "only return the user if the email completely match" do
      user = insert(:user)
      refute Accounts.get_user_by_name_or_email("1" <> user.email)
    end

    test "only return the user if confirmed_at is not null. use email" do
      user = insert(:user_not_confirmed)
      refute Accounts.get_user_by_name_or_email(user.email)
    end

    test "only return the user if confirmed_at is not null. use name" do
      user = insert(:user_not_confirmed)
      refute Accounts.get_user_by_name_or_email(user.name)
    end

    test "returns the user if the name exists" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user_by_name_or_email(user.name)
    end

    test "returns the user if the email exists" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user_by_name_or_email(user.email)
    end
  end

  describe "onboarding_finished?/1" do
    test "returns true if user_onboarding exists" do
      user = insert(:user)
      insert(:user_onboarding, user: user)

      assert Accounts.onboarding_finished?(user)
    end

    test "returns false if user_onboarding does not exist" do
      user = insert(:user)

      refute Accounts.onboarding_finished?(user)
    end
  end
end
