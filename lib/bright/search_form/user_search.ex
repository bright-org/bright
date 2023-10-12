defmodule Bright.SearchForm.UserSearch do
  @moduledoc """
  ユーザー検索の稼働条件フォームモデル
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.SearchForm.SkillSearch

  embedded_schema do
    field :desired_income, :integer
    field :office_work, :boolean, default: false
    field :office_pref, :string
    field :office_working_hours, :string
    field :office_work_holidays, :boolean, default: false
    field :remote_work, :boolean, default: false
    field :remote_working_hours, :string
    field :remote_work_holidays, :boolean, default: false
    field :wish_employed, :boolean, default: false
    field :wish_change_job, :boolean, default: false
    field :wish_side_job, :boolean, default: false
    field :wish_freelance, :boolean, default: false
    embeds_many :skills, SkillSearch
  end

  @doc false
  def changeset(user_search, attrs) do
    user_search
    |> cast(attrs, [
      :desired_income,
      :office_work,
      :office_pref,
      :office_working_hours,
      :office_work_holidays,
      :remote_work,
      :remote_working_hours,
      :remote_work_holidays,
      :wish_employed,
      :wish_change_job,
      :wish_side_job,
      :wish_freelance
    ])
    |> cast_embed(:skills,
      with: &SkillSearch.changeset/2,
      sort_param: :skills_sort,
      drop_param: :skills_drop
    )
  end
end
