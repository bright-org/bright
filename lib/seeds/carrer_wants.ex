defmodule Bright.Seeds.CareerWants do
  @moduledoc """
  開発用のやりたいことSeedデータ
  """
  alias Bright.{Repo, Jobs, SkillPanels}
  alias Bright.Jobs.CareerWant

  @data [
    %{name: "Webアプリを作りたい", position: 1},
    %{name: "スマホアプリを作りたい", position: 2},
    %{name: "Webサイトをデザインしたい", position: 3},
    %{name: "アプリやWebの広告をしたい", position: 4},
    %{name: "AIをやってみたい", position: 5},
    %{name: "クラウドインフラを構築したい", position: 6},
    %{name: "とにかく即戦力ではじめたい", position: 7},
    %{name: "個人でアプリを開発したい", position: 8}
  ]

  def delete() do
    CareerWant
    |> Repo.all()
    |> Enum.each(&Repo.delete(&1))
  end

  def insert() do
    skill_panels =
      SkillPanels.list_skill_panels()
      |> Repo.preload(:career_field)
      |> Enum.group_by(& &1.career_field.name_en)

    Enum.each(@data, fn w ->
      case w.position do
        1 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["engineer"], 3)
          rand_insert(want, skill_panels["designer"], 2)
          rand_insert(want, skill_panels["marketer"], 1)

        2 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["engineer"], 2)
          rand_insert(want, skill_panels["designer"], 2)
          rand_insert(want, skill_panels["marketer"], 1)

        3 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["engineer"], 2)
          rand_insert(want, skill_panels["designer"], 3)

        4 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["marketer"], 2)

        5 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["engineer"], 2)
          rand_insert(want, skill_panels["infra"], 3)

        6 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["infra"], 3)

        7 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["engineer"], 3)
          rand_insert(want, skill_panels["infra"], 3)
          rand_insert(want, skill_panels["designer"], 3)
          rand_insert(want, skill_panels["marketer"], 3)

        8 ->
          {:ok, want} = Jobs.create_career_want(w)
          rand_insert(want, skill_panels["engineer"], 3)
          rand_insert(want, skill_panels["infra"], 2)
          rand_insert(want, skill_panels["designer"], 2)
          rand_insert(want, skill_panels["marketer"], 2)
      end
    end)
  end

  def rand_insert(want, list, num) do
    list
    |> Enum.take_random(num)
    |> Enum.each(fn panel ->
      Jobs.create_career_want_skill_panel(%{career_want_id: want.id, skill_panel_id: panel.id})
    end)
  end
end
