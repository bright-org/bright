defmodule Bright.UserFactory do
  @moduledoc """
  Factory for Bright.Accounts.User
  """

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Bright.Accounts.User{
          name: sequence(:name, &"user_name_#{&1}"),
          email: sequence(:email, &"user#{&1}@example.com"),
          hashed_password: Bcrypt.hash_pwd_salt(valid_user_password()),
          password_registered: true,
          confirmed_at: NaiveDateTime.utc_now()
        }
      end

      def user_not_confirmed_factory do
        build(:user, confirmed_at: nil)
      end

      def user_registered_by_social_auth_factory do
        build(:user, password_registered: false)
      end

      def user_before_registration_factory do
        build(:user_not_confirmed, password: valid_user_password(), hashed_password: nil)
      end

      def create_user_with_password(password) do
        insert(:user, hashed_password: Bcrypt.hash_pwd_salt(password))
      end

      def unique_user_name, do: "user_name_#{System.unique_integer()}"
      def unique_user_email, do: "user#{System.unique_integer()}@example.com"
      def valid_user_password, do: "hello world2!"

      def with_user_profile(%Bright.Accounts.User{} = user) do
        insert(:user_profile, user: user)
        user
      end
    end
  end
end
