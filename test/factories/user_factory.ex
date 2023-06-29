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
          confirmed_at: NaiveDateTime.utc_now()
        }
      end

      def user_not_confirmed_factory do
        build(:user, confirmed_at: nil)
      end

      def user_before_registration_factory do
        build(:user, password: valid_user_password(), hashed_password: nil)
      end

      def unique_user_name, do: "user_name_#{System.unique_integer()}"
      def unique_user_email, do: "user#{System.unique_integer()}@example.com"
      def valid_user_password, do: "hello world!"
    end
  end
end
