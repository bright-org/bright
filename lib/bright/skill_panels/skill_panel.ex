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
    attrs = merge_skill_classes_rank(attrs)

    skill_panel
    |> cast(attrs, [:locked_date, :name])
    |> cast_assoc(:skill_classes,
      with: &SkillClass.changeset/2,
      sort_param: :skill_classes_sort,
      drop_param: :skill_classes_drop
    )
    |> validate_required([:name])
  end

  # 紐づくスキルクラスのrankを順に設定
  defp merge_skill_classes_rank(%{"skill_classes_sort" => _} = attrs) do
    # Dynamic form 仕様を想定
    sorts = attrs["skill_classes_sort"]

    attrs
    |> Map.update!("skill_classes", fn skill_classes_attrs ->
      skill_classes_attrs
      |> Map.new(fn {numth, skill_class_attrs} ->
        rank = Enum.find_index(sorts, & &1 == numth) + 1
        skill_class_attrs = Map.put(skill_class_attrs, "rank", rank)

        {numth, skill_class_attrs}
      end)
    end)
  end

  defp merge_skill_classes_rank(%{skill_classes: _} = attrs) do
    # 直接的に属性を指定した生成を想定
    attrs
    |> Map.update!(:skill_classes, fn skill_classes_attrs ->
      skill_classes_attrs
      |> Enum.with_index(1)
      |> Enum.map(fn {skill_class_attrs, rank} ->
        Map.put(skill_class_attrs, :rank, rank)
      end)
    end)
  end

  defp merge_skill_classes_rank(attrs), do: attrs
end
