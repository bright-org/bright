defmodule Bright.UserProfileFactory do
  @moduledoc """
  Factory for Bright.UserProfiles.UserProfile
  """

  defmacro __using__(_opts) do
    quote do
      def user_profile_factory do
        %Bright.UserProfiles.UserProfile{
          user: build(:user),
          title: Faker.Lorem.word(),
          detail: "私は" <> Faker.Lorem.word() <> "です",
          icon_file_path: "gs://" <> Faker.Lorem.word() <> "/" <> Faker.Lorem.word(),
          twitter_url: "https://twitter.com/" <> Faker.Lorem.word(),
          facebook_url: "https://www.facebook.com/" <> Faker.Lorem.word(),
          github_url: "https://github.com/" <> Faker.Lorem.word()
        }
      end
    end
  end
end
