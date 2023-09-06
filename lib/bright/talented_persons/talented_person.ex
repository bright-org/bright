defmodule Bright.TalentedPersons.TalentedPerson do
  @moduledoc """
  優秀なエンジニア紹介を扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User
  alias Bright.Teams.Team

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "talented_persons" do
    belongs_to :introducer_user, User
    belongs_to :fave_user, User
    belongs_to :team, Team
    field :fave_point, :string

    timestamps()
  end

  @doc false
  def changeset(talented_person, attrs) do
    talented_person
    |> cast(attrs, [:introducer_user_id, :fave_user_id, :team_id, :fave_point])
    |> validate_required([:introducer_user_id, :fave_user_id, :team_id, :fave_point])
  end
end
