defmodule Bright.SkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillClass
  alias Bright.Jobs.JobSkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_panels" do
    field :name, :string

    has_many :skill_classes, SkillClass, preload_order: [asc: :class], on_replace: :delete
    has_many :job_skill_panels, JobSkillPanel, on_replace: :delete
    has_many :jobs, through: [:job_skill_panels, :job]

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
