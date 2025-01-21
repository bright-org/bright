defmodule Bright.CareerGroups.CareerGroup do
  @moduledoc """
  キャリアフィールドの上位のグループ
  ITや医療など業種自体が違うグルーピングを行う
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.CareerGroups.CareerGroupCareerField
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_groups" do
    field :name, :string
    field :position, :integer
    field :type, Ecto.Enum, values: Ecto.Enum.values(User, :type)

    has_many :career_group_career_fields, CareerGroupCareerField,
      on_replace: :delete,
      on_delete: :delete_all

    has_many :career_fields, through: [:career_group_career_fields, :career_field]

    timestamps()
  end

  @doc false
  def changeset(career_group, attrs) do
    career_group
    |> cast(attrs, [:name, :type, :position])
    |> cast_assoc(:career_group_career_fields,
      with: &CareerGroupCareerField.changeset/2,
      sort_param: :career_group_career_fields_sort,
      drop_param: :career_group_career_fields_drop
    )
    |> validate_required([:name, :type, :position])
  end
end
