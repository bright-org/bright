defmodule Bright.Seeds.Job do
  @moduledoc """
  開発用のジョブSeedデータ
  """
  alias Bright.Repo

  alias Bright.Jobs
  alias Bright.Jobs.Job

  @engineer [
    %{
      rank: "master",
      position: 1,
      name: "プロダクトオーナー",
      description: "高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。"
    },
    %{
      rank: "master",
      position: 2,
      name: "プロダクトマネージャー",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "master",
      position: 3,
      name: "プロジェクトマネージャー",
      description: "高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。"
    },
    %{
      rank: "master",
      position: 4,
      name: "プロダクトマーケティングマネージャー",
      description: "高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。"
    },
    %{
      rank: "advanced",
      position: 5,
      name: "リードエンジニア",
      description: "高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。"
    },
    %{
      rank: "advanced",
      position: 6,
      name: "レビュアー",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "advanced",
      position: 7,
      name: "情シス",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "advanced",
      position: 8,
      name: "テックリード",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "advanced",
      position: 9,
      name: "ITコンサルタント",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "advanced",
      position: 10,
      name: "ITデジタルマーケッター",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 11,
      name: "Webアプリ開発",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 12,
      name: "スマホアプリ開発",
      description: "スマホアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 13,
      name: "デスクトップアプリ開発",
      description: "デスクトップアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 14,
      name: "データサイエンティスト",
      description: "データ分析基盤を一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 15,
      name: "基幹システム",
      description: "基幹システムを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 16,
      name: "組み込みエンジニア",
      description: "組み込みシステムを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    }
  ]

  @infra []
  @designer []
  @marketer []

  def delete() do
    Job
    |> Repo.all()
    |> Enum.each(&Repo.delete(&1))
  end

  def insert() do
    Jobs.list_career_fields()
    |> Enum.each(fn c ->
      case c.name_en do
        "engineer" -> create_job(@engineer, c.id)
        "infra" -> create_job(@infra, c.id)
        "designer" -> create_job(@designer, c.id)
        "marketer" -> create_job(@marketer, c.id)
      end
    end)
  end

  def create_job(job_list, career_field_id) do
    Enum.each(job_list, fn job ->
      job
      |> Map.put(:career_field_id, career_field_id)
      |> Jobs.create_job()
    end)
  end
end
