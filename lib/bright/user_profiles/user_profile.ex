defmodule Bright.UserProfiles.UserProfile do
  @moduledoc """
  ユーザープロフィールを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_profiles" do
    belongs_to :user, Bright.Accounts.User
    field :title, :string
    field :detail, :string
    field :icon_file_path, :string
    field :twitter_url, :string
    field :facebook_url, :string
    field :github_url, :string

    timestamps()
  end

  @doc false
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [
      :user_id,
      :title,
      :detail,
      :icon_file_path,
      :twitter_url,
      :facebook_url,
      :github_url
    ])
    |> validate_required([
      :user_id
    ])
  end
end
