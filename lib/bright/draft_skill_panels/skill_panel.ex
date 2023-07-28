defmodule Bright.DraftSkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。管理画面でのCRUD操作対象。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillPanels.DraftSkillClass

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_panels" do
    field :name, :string

    has_many :draft_skill_classes, DraftSkillClass,
      preload_order: [asc: :class],
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(skill_panel, attrs) do
    skill_panel
    |> cast(attrs, [:name])
    |> cast_assoc(:draft_skill_classes,
      with: &DraftSkillClass.changeset/2,
      sort_param: :draft_skill_classes_sort,
      drop_param: :draft_skill_classes_drop
    )
    |> change_draft_skill_classes_class()
    |> validate_required([:name])
  end

  # 紐づくスキルクラスのclassを順に設定したchangesetを返す。
  # - attrsは様々な形(atomキー, DynamicForm由来,...)があるためchangesetの状態で設定している。
  defp change_draft_skill_classes_class(
         %{
           changes: %{draft_skill_classes: draft_skill_classes}
         } = changeset
       ) do
    draft_skill_classes_changeset =
      draft_skill_classes
      |> Enum.with_index(1)
      |> Enum.map(fn {draft_skill_class_changeset, class} ->
        Map.update!(draft_skill_class_changeset, :changes, &Map.put(&1, :class, class))
      end)

    changeset
    |> Map.update!(:changes, &Map.put(&1, :draft_skill_classes, draft_skill_classes_changeset))
  end

  defp change_draft_skill_classes_class(changeset), do: changeset
end
