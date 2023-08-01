defmodule Bright.Jobs.JobSkillPanel do
  @moduledoc """
  ジョブとスキルパネルの関連付けを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Jobs.Job
  alias Bright.SkillPanels.SkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "job_skill_panels" do
    belongs_to :job, Job
    belongs_to :skill_panel, SkillPanel

    timestamps()
  end

  @doc false
  def changeset(job_skill_panel, attrs) do
    job_skill_panel
    |> cast(attrs, [:job_id, :skill_panel_id])
    |> validate_required([:job_id, :skill_panel_id])
  end
end
