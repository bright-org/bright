defmodule Bright.Seeds.CareerWants do
  @moduledoc """
  開発用のやりたいことSeedデータ
  """
  alias Bright.{Repo, CareerWants, Jobs}
  alias Bright.CareerWants.CareerWant

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
    jobs =
      Jobs.list_jobs()
      |> Repo.preload(:career_fields)
      |> Enum.filter(&(&1.rank == :basic))
      |> Enum.group_by(&List.first(&1.career_fields).name_en)

    Enum.each(@data, fn w ->
      case w.position do
        1 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["engineer"], 3, "Web")
          rand_insert(want, jobs["designer"], 2, "Web")
          rand_insert(want, jobs["marketer"], 1)

        2 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["engineer"], 2, "スマホ")
          rand_insert(want, jobs["designer"], 2)
          rand_insert(want, jobs["marketer"], 1)

        3 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["engineer"], 2, "Web")
          rand_insert(want, jobs["designer"], 3, "デザイナー")

        4 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["marketer"], 2)

        5 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["engineer"], 2, "データサイエンティスト")
          rand_insert(want, jobs["product"], 3)

        6 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["product"], 3)

        7 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["engineer"], 3)
          rand_insert(want, jobs["product"], 3)
          rand_insert(want, jobs["designer"], 3)
          rand_insert(want, jobs["marketer"], 3)

        8 ->
          {:ok, want} = CareerWants.create_career_want(w)
          rand_insert(want, jobs["engineer"], 3, "アプリ")
          rand_insert(want, jobs["product"], 2)
          rand_insert(want, jobs["designer"], 2)
          rand_insert(want, jobs["marketer"], 2)
      end
    end)
  end

  def rand_insert(want, list, num) do
    list
    |> Enum.take_random(num)
    |> Enum.each(fn job ->
      CareerWants.create_career_want_job(%{
        career_want_id: want.id,
        job_id: job.id
      })
    end)
  end

  def rand_insert(want, list, num, word) do
    list
    |> Enum.filter(&String.match?(&1.name, ~r/#{word}/))
    |> Enum.take_random(num)
    |> Enum.each(fn job ->
      CareerWants.create_career_want_job(%{
        career_want_id: want.id,
        job_id: job.id
      })
    end)
  end
end
