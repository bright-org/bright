defmodule Bright.UserJobProfiles.UserJobProfile do
  @moduledoc """
  ユーザーの求職情報を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  @working_hours ~w/40h 80h 160h 200h 240h/a
  @pref ~w/北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県 茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県 新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県/a

  schema "user_job_profiles" do
    field :availability_date, :date
    field :desired_income, :integer
    field :job_searching, :boolean, default: false
    field :office_working_hours, Ecto.Enum, values: @working_hours
    field :office_pref, Ecto.Enum, values: @pref
    field :office_work, :boolean, default: false
    field :office_work_holidays, :boolean, default: false
    field :remote_working_hours, Ecto.Enum, values: @working_hours
    field :remote_work_holidays, :boolean, default: false
    field :remove_work, :boolean, default: false
    field :wish_change_job, :boolean, default: false
    field :wish_employed, :boolean, default: false
    field :wish_freelance, :boolean, default: false
    field :wish_side_job, :boolean, default: false

    belongs_to :user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_job_profile, attrs) do
    user_job_profile
    |> cast(attrs, [
      :job_searching,
      :wish_employed,
      :wish_change_job,
      :wish_side_job,
      :wish_freelance,
      :availability_date,
      :office_work,
      :office_work_holidays,
      :office_pref,
      :office_working_hours,
      :remove_work,
      :remote_work_holidays,
      :remote_working_hours,
      :desired_income,
      :user_id
    ])
    |> validate_required([
      :job_searching,
      :user_id
    ])
  end
end
