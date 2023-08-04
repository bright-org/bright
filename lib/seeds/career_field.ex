defmodule Bright.Seeds.CareerField do
  @moduledoc """
  開発用のキャリアフィールドSeedデータ
  """
  alias Bright.Repo
  alias Bright.Jobs
  alias Bright.Jobs.CareerField

  @data [
    %{name_en: "engineer", name_ja: "エンジニア", position: 1},
    %{name_en: "infra", name_ja: "インフラ", position: 2},
    %{name_en: "designer", name_ja: "デザイナー", position: 3},
    %{name_en: "marketer", name_ja: "マーケッター", position: 4}
  ]
  def delete() do
    CareerField
    |> Repo.all()
    |> Enum.each(&Repo.delete(&1))
  end

  def insert() do
    Enum.each(@data, fn c ->
      Jobs.create_career_field(c)
    end)
  end
end
