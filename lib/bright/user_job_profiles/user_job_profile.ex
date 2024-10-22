defmodule Bright.UserJobProfiles.UserJobProfile do
  @moduledoc """
  ユーザーの求職情報を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  @working_hours ~w/月160h以上 月140h~159h 月120h~139h 月100h~119h 月80h~99h 月79h以下/a
  @pref ~w/北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県 茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県 新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県 海外/a
  @wish_job [
    wish_employed: "要OJT",
    wish_change_job: "現業以外も可",
    wish_side_job: "副業も可",
    wish_freelance: "業務委託も可"
  ]

  schema "user_job_profiles" do
    field :desired_income, :decimal
    field :job_searching, :boolean, default: true
    field :office_working_hours, Ecto.Enum, values: @working_hours
    field :office_pref, Ecto.Enum, values: @pref
    field :office_work, :boolean, default: false
    field :office_work_holidays, :boolean, default: false
    field :remote_working_hours, Ecto.Enum, values: @working_hours
    field :remote_work_holidays, :boolean, default: false
    field :remote_work, :boolean, default: false
    field :wish_change_job, :boolean, default: false
    field :wish_employed, :boolean, default: false
    field :wish_freelance, :boolean, default: false
    field :wish_side_job, :boolean, default: false
    field :work_style, :string, virtual: true

    belongs_to :user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_job_profile, attrs) do
    attrs = convert_work_style_to_works(attrs)

    user_job_profile
    |> convert_works_to_work_style()
    |> cast(attrs, [
      :job_searching,
      :wish_employed,
      :wish_change_job,
      :wish_side_job,
      :wish_freelance,
      :office_work,
      :office_work_holidays,
      :office_pref,
      :office_working_hours,
      :remote_work,
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

  def wish_job_type(user_job_profile) do
    job_types =
      @wish_job
      |> Enum.map(fn {key, value} ->
        if Map.get(user_job_profile, key), do: value
      end)
      |> Enum.filter(& &1)

    case length(job_types) do
      0 -> "-"
      _ -> Enum.join(job_types, ", ")
    end
  end

  defp convert_work_style_to_works(attrs) do
    case Map.keys(attrs) |> List.first() |> is_atom() do
      true -> convert_work_style_to_works_atom(attrs)
      false -> convert_work_style_to_works_string(attrs)
    end
  end

  defp convert_work_style_to_works_atom(attrs) do
    case Map.get(attrs, :work_style) do
      "both" -> Map.merge(attrs, %{:office_work => true, :remote_work => true})
      "office" -> Map.merge(attrs, %{:office_work => true, :remote_work => false})
      "remote" -> Map.merge(attrs, %{:office_work => false, :remote_work => true})
      _ -> attrs
    end
  end

  defp convert_work_style_to_works_string(attrs) do
    case Map.get(attrs, "work_style") do
      "both" -> Map.merge(attrs, %{"office_work" => true, "remote_work" => true})
      "office" -> Map.merge(attrs, %{"office_work" => true, "remote_work" => false})
      "remote" -> Map.merge(attrs, %{"office_work" => false, "remote_work" => true})
      _ -> attrs
    end
  end

  defp convert_works_to_work_style(user_profile) do
    case user_profile do
      %{office_work: true, remote_work: true} -> Map.put(user_profile, :work_style, "both")
      %{office_work: true, remote_work: false} -> Map.put(user_profile, :work_style, "office")
      %{office_work: false, remote_work: true} -> Map.put(user_profile, :work_style, "remote")
      _ -> Map.put(user_profile, :work_style, nil)
    end
  end
end
