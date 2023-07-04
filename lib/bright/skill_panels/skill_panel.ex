defmodule Bright.SkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillClass

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_panels" do
    field :locked_date, :date
    field :name, :string

    has_many :skill_classes, SkillClass, preload_order: [asc: :rank], on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(skill_panel, attrs) do
    skill_panel
    |> cast(attrs, [:locked_date, :name])
    |> cast_assoc(:skill_classes,
      with: &SkillClass.changeset/2,
      sort_param: :skill_classes_sort,
      drop_param: :skill_classes_drop
    )
    |> change_skill_classes_rank()
    |> validate_required([:name])
  end

  # 紐づくスキルクラスのrankを順に設定したchangesetを返す。
  # - attrsは様々な形(atomキー, DynamicForm由来,...)があるためchangesetの状態で設定している。
  defp change_skill_classes_rank(
         %{
           changes: %{skill_classes: skill_classes}
         } = changeset
       ) do
    skill_classes_changeset =
      skill_classes
      |> Enum.with_index(1)
      |> Enum.map(fn {skill_class_changeset, rank} ->
        Map.update!(skill_class_changeset, :changes, &Map.put(&1, :rank, rank))
      end)

    changeset
    |> Map.update!(:changes, &Map.put(&1, :skill_classes, skill_classes_changeset))
  end

  defp change_skill_classes_rank(changeset), do: changeset
end
