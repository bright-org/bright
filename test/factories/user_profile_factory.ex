defmodule Bright.UserProfileFactory do
  @moduledoc """
  Factory for Bright.UserProfiles.UserProfile
  """

  defmacro __using__(_opts) do
    quote do
      def user_profile_factory do
        %Bright.UserProfiles.UserProfile{
          user: build(:user),
          title: sequence(:title, &"#{Faker.Lorem.word()}#{&1}"),
          detail: sequence(:detail, &"私は#{Faker.Lorem.word()}#{&1}です"),
          icon_file_path: sequence(:icon_file_path, &"users/profile_icon_#{&1}.png"),
          twitter_url: sequence(:twitter_url, &"https://twitter.com/#{Faker.Lorem.word()}#{&1}"),
          facebook_url:
            sequence(:facebook_url, &"https://www.facebook.com/#{Faker.Lorem.word()}#{&1}"),
          github_url: sequence(:facebook_url, &"https://github.com/#{Faker.Lorem.word()}#{&1}")
        }
      end
    end
  end
end
