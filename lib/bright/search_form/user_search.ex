defmodule Bright.SearchForm.UserSearch do
  @moduledoc """
  ユーザー検索の稼働条件フォームモデル
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.SearchForm.SkillSearch

  embedded_schema do
    field :pj_start, :string, default: ""
    field :pj_end, :string, default: ""
    field :pj_end_undecided, :boolean, default: false
    field :budget, :integer
    field :office_work, :boolean, default: false
    field :office_pref, :string
    field :office_work_hours, :string
    field :office_work_holidays, :boolean, default: false
    field :remote_work, :boolean, default: false
    field :remote_work_hours, :string
    field :remote_work_holidays, :boolean, default: false
    embeds_many :skills, SkillSearch
  end

  @doc false
  def changeset(user_search, attrs) do
    user_search
    |> cast(attrs, [
      :pj_start,
      :pj_end,
      :pj_end_undecided,
      :budget,
      :office_work,
      :office_pref,
      :office_work_hours,
      :office_work_holidays,
      :remote_work,
      :remote_work_hours,
      :remote_work_holidays
    ])
    |> cast_embed(:skills,
      with: &SkillSearch.changeset/2,
      sort_param: :skills_sort,
      drop_param: :skills_drop
    )
  end
end
