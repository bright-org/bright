defmodule Bright.SearchForm.SkillSearch do
  @moduledoc """
  ユーザー検索のスキルフォームモデル
  """

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :career_field, :string
    field :skill_panel, :string
    field :class, :integer
    field :level, :string
  end

  @doc false
  def changeset(user_search, attrs) do
    user_search
    |> cast(attrs, [:career_field, :skill_panel, :class, :level])
    |> validate_required([:career_field, :skill_panel])
  end
end
