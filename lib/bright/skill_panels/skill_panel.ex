defmodule Bright.SkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Jobs.JobSkillPanel
  alias Bright.SkillPanels.SkillClass
  alias Bright.CareerFields.CareerFieldSkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_panels" do
    field :name, :string

    has_one :job_skill_panel, JobSkillPanel
    has_many :skill_classes, SkillClass, preload_order: [asc: :class], on_replace: :delete
    has_many :career_field_skill_panels, CareerFieldSkillPanel, on_replace: :delete
    has_many :career_fields, through: [:career_field_skill_panels, :career_field]

    timestamps()
  end

  @doc false
  def changeset(skill_panel, attrs) do
    skill_panel
    |> cast(attrs, [:name])
    |> cast_assoc(:skill_classes,
      with: &SkillClass.changeset/2,
      sort_param: :skill_classes_sort,
      drop_param: :skill_classes_drop
    )
    |> cast_assoc(:career_field_skill_panels,
      with: &CareerFieldSkillPanel.changeset/2,
      sort_param: :career_field_skill_panel_sort,
      drop_param: :career_field_skill_panel_drop
    )
    |> change_skill_classes_class()
    |> validate_required([:name])
  end

  # 紐づくスキルクラスのclassを順に設定したchangesetを返す。
  # - attrsは様々な形(atomキー, DynamicForm由来,...)があるためchangesetの状態で設定している。
  defp change_skill_classes_class(
         %{
           changes: %{skill_classes: skill_classes}
         } = changeset
       ) do
    skill_classes_changeset =
      skill_classes
      |> Enum.with_index(1)
      |> Enum.map(fn {skill_class_changeset, class} ->
        Map.update!(skill_class_changeset, :changes, &Map.put(&1, :class, class))
      end)

    changeset
    |> Map.update!(:changes, &Map.put(&1, :skill_classes, skill_classes_changeset))
  end

  defp change_skill_classes_class(changeset), do: changeset
end
