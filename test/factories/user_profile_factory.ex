defmodule Bright.UserProfileFactory do
  @moduledoc """
  Factory for Bright.UserProfiles.UserProfile
  """

  defmacro __using__(_opts) do
    quote do
      def user_profile_factory do
        user = insert(:user)

        %Bright.UserProfiles.UserProfile{
          user_id: user.id,
          title: Faker.Lorem.word(),
          detail: "私は" <> Faker.Lorem.word() <> "です",
          icon_file_path: "gs://" <> Faker.Lorem.word() <> "/" <> user.name,
          twitter_url: "https://twitter.com/" <> user.name,
          facebook_url: "https://www.facebook.com/" <> user.name,
          github_url: "https://github.com/" <> user.name
        }
      end
    end
  end
end
