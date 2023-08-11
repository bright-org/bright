defmodule Bright.Seeds.Job do
  @moduledoc """
  開発用のジョブSeedデータ
  """

  alias Bright.Repo

  alias Bright.{Jobs, CareerFields, SkillPanels}
  alias Bright.CareerWants.CareerWantJob
  alias Bright.Jobs.{Job, JobSkillPanel}
  alias Bright.CareerFields.CareerFieldJob

  @engineer [
    %{
      rank: "expert",
      position: 1,
      name: "PO(プロダクトオーナー)",
      description:
        "プロダクトオーナーとは、製品開発における方向性を決める責任者を指します。 顧客の要望を正確に捉えて、プロダクト（製品）の価値を最大限化させることに責任を持つ職務です。 プロダクトオーナーは、主にスクラム開発に標準的な職務として導入されています。"
    },
    %{
      rank: "expert",
      position: 2,
      name: "PdM(プロダクトマネージャー)",
      description:
        "プロダクト マネージャーとは、顧客のニーズ、製品や機能が満たす大きなビジネス目標を特定し、製品の成功とは何かを明確にし、そのビジョンを実現するためにチームをまとめる人のことです。"
    },
    %{
      rank: "expert",
      position: 3,
      name: "PM(プロジェクトマネージャー)",
      description:
        "プロダクトマネージャーは、プロダクトマネジメントの実践として知られる組織の製品開発に責任を持つ専門職です。プロダクトマネージャーは、製品の背後にあるビジネス戦略を立てながら、その機能要件を特定し立ち上げをリードします。"
    },
    %{
      rank: "expert",
      position: 4,
      name: "テックリード",
      description:
        "テックリードは、エンジニアチームのリーダーとなる人材のことです。 エンジニアは個人作業が多い職種ではありますが、プロジェクトに属し、そのプロジェクトの共通ゴールに向かって、各エンジニアが行動をすることが一般的です。 そこで、技術的な面で支える人材が必要になります。 その役割を担うのがテックリードです。"
    },
    %{
      rank: "expert",
      position: 5,
      name: "エンジニアリングマネージャ",
      description:
        "EM（Engineering Manager）とは、エンジニアのマネジメントを行う職種です。 技術分野の専門知識を持ち、エンジニアチームをリードしてプロジェクトを成功に導く役割を担います。 企業によって求められる役割は変化しますが、基本的には技術的な知識・スキルとマネジメント力の両方が求められるポジションです。"
    },
    %{
      rank: "expert",
      position: 6,
      name: "VPoE",
      description:
        "VPoEとは、一般的に企業の技術部門をマネジメントする役職を意味します。 VPoEはエンジニアの採用や評価などに関する責任を負い、エンジニアが最大限にスキルを発揮できる環境を整備し、より効率的で質の高い開発をするための体制を整える役割を持ちます。"
    },
    %{
      rank: "advanced",
      position: 1,
      name: "リードエンジニア",
      description: "高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。"
    },
    %{
      rank: "advanced",
      position: 2,
      name: "SRE",
      description:
        "SREとは「サイト・リライアビリティ・エンジニア（Site Reliability Engineering）」の略称で、Googleが提唱する「システムの運用・管理方法とそれに対するエンジニアの役割」を指します。 つまり、SREエンジニアとは、Web系のシステムを最適に運用するためのエンジニアのことをいいます。"
    },
    %{
      rank: "advanced",
      position: 3,
      name: "アーキテクト",
      description:
        "システム開発における共通仕様・要件定義やシステムのあり方を検討・提案し、システム全体の方向性や仕組みから運用・保守要件まで提示することができる技術者のことを指します。 そのため、プログラマーやシステムエンジニアとは違った、多種多様な知識やスキルが必要とされます。"
    },
    %{
      rank: "advanced",
      position: 4,
      name: "ITコンサルタント",
      description:
        "Tコンサルタントは、クライアント企業の経営戦略をヒアリングし、それに沿ったIT投資計画の策定、必要なツールの導入・支援を行うことが仕事です。 費用対効果やスケジュールを含め、システムの分析・選定についてもITコンサルタントの役割です。"
    },
    %{
      rank: "advanced",
      position: 5,
      name: "QA(品質保証)エンジニア",
      description:
        "QAエンジニア（quality assurance engineer）・品質保証エンジニアとは、ソフトウェアの品質保証を目的とした品質計画の立案や動作テスト、品質管理を行うエンジニアです。 近年では、ソフトウェアの品質管理だけではなく、セキュリティ担保の観点からもQAエンジニアの需要が高まってきています。"
    },
    %{
      rank: "advanced",
      position: 6,
      name: "セールスエンジニア",
      description:
        "セールスエンジニアは、技術的な側面から営業をサポートする職種です。 ソフトウェアや電子機器をセールスするにあたって、製品の説明や、お客様の意見をきくことで新たな提案をおこない、製品のよさを伝えます。 実際に使ってもらうための実演をすることもあります。"
    },
    %{
      rank: "basic",
      position: 1,
      name: "Webアプリ開発者 Elixir",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 2,
      name: "Webアプリ開発者 Go",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 3,
      name: "Webアプリ開発者 PHP",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 4,
      name: "Webアプリ開発者 Java",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 5,
      name: "Webアプリ開発者 Ruby",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 6,
      name: "Webアプリ開発者 Python",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 7,
      name: "Webアプリ開発者 React",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 8,
      name: "Webアプリ開発者 C#／VB.net",
      description: "Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 9,
      name: "スマホアプリ開発者 Elixir",
      description: "スマホアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 10,
      name: "スマホアプリ開発者 ReactNative",
      description: "スマホアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 11,
      name: "スマホアプリ開発者 Flutter",
      description: "スマホアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 12,
      name: "スマホアプリ開発者 Kotlin",
      description: "スマホアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 13,
      name: "スマホアプリ開発者 Swift",
      description: "スマホアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 14,
      name: "デスクトップアプリ開発者 Elixir",
      description: "デスクトップアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 15,
      name: "デスクトップアプリ開発者 C#",
      description: "デスクトップアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 16,
      name: "データサイエンティスト Python",
      description: "データ分析基盤を一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 17,
      name: "データサイエンティスト Elixir",
      description: "データ分析基盤を一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 18,
      name: "データサイエンティスト Excel",
      description: "データ分析基盤を一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 19,
      name: "データサイエンティスト SQL",
      description: "データ分析基盤を一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 20,
      name: "基幹システム開発者 Java",
      description: "基幹システムを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    },
    %{
      rank: "basic",
      position: 21,
      name: "組み込みエンジニア Elixir",
      description: "組み込みシステムを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    }
  ]

  @infra [
    %{
      rank: "expert",
      position: 1,
      name: "AWS プロフェッショナル",
      description: "AWSのプロフェッショナル"
    },
    %{
      rank: "expert",
      position: 2,
      name: "Google Cloud プロフェッショナル",
      description: "Google Cloudのプロフェッショナル"
    },
    %{
      rank: "expert",
      position: 3,
      name: "Azure エキスパート",
      description: "Azureのエキスパート"
    },
    %{
      rank: "advanced",
      position: 1,
      name: "AWS アソシエイト",
      description: "AWSアソシエイト資格保持者"
    },
    %{
      rank: "advanced",
      position: 2,
      name: "Google Cloud アソシエイト",
      description: "Google Cloudアソシエイト資格保持者"
    },
    %{
      rank: "advanced",
      position: 3,
      name: "Azure アソシエイト",
      description: "Azureアソシエイト資格保持者"
    },
    %{
      rank: "basic",
      position: 1,
      name: "AWS プラクティショナー",
      description: "AWSプラクティショナー資格保持者"
    },
    %{
      rank: "basic",
      position: 2,
      name: "Google Cloud ファンダメンタルズ",
      description: "Google Cloud ファンダメンタルズ資格保持者"
    },
    %{
      rank: "basic",
      position: 3,
      name: "Azure ファンダメンタルズ",
      description: "Azure ファンダメンタルズ資格保持者"
    }
  ]
  @designer [
    %{
      rank: "expert",
      position: 1,
      name: "Webディレクションマネージャ",
      description: "Webディレクションのマネージャ"
    },
    %{
      rank: "expert",
      position: 2,
      name: "プロダクトデザイナー",
      description:
        "既存の製品の開発、新機能の設計、メンテナンスに重点を置きます。 また営業やマーケティングチームと密接に連携し、競合他社や市場、ユーザーの調査を通じてビジネスバリューの機会を見出します。"
    },
    %{
      rank: "expert",
      position: 3,
      name: "アートディレクター",
      description: "アートディレクターは、広告やロゴ、アイキャッチなどの視覚的な制作物の取りまとめと行う"
    },
    %{
      rank: "advanced",
      position: 1,
      name: "Webデザインディレクター",
      description:
        "依頼の背景や要望などを聞き出して情報を整理し、それを元にコンテンツの企画を行います。また、作成するサイトの目的や予算に合わせて最適なスタッフや外注先を選定する"
    },
    %{
      rank: "advanced",
      position: 2,
      name: "Web開発ディレクター",
      description: "開発ディレクターは、新規サイト構築時にどのようなサイトにするかを決め、本番リリースまでを担います。"
    },
    %{
      rank: "advanced",
      position: 3,
      name: "UX・UIディレクター",
      description: "UX・UIのディレクター"
    },
    %{
      rank: "advanced",
      position: 4,
      name: "UXアナリスト",
      description: "UXのアナリスト"
    },
    %{
      rank: "basic",
      position: 1,
      name: "Webデザイナー",
      description: "Webデザインを作成する"
    },
    %{
      rank: "basic",
      position: 2,
      name: "アプリUIデザイナー",
      description: "UIデザイン・プロトタイプを作成・設計する"
    },
    %{
      rank: "basic",
      position: 3,
      name: "UXデザイナー",
      description: "UXデザインを設計する"
    },
    %{
      rank: "basic",
      position: 4,
      name: "UXリサーチャー",
      description: "UXをリサーチする"
    },
    %{
      rank: "basic",
      position: 5,
      name: "グラフィックデザイナー",
      description: "ロゴ・イラストを作成する"
    }
  ]
  @marketer [
    %{
      rank: "expert",
      position: 1,
      name: "ブランドマネージャ",
      description: "ブランド・マネージャーは、ブランドの資産としての価値を高めるために、その構築から管理までの活動全般にわたる広範囲の経営的責任を担います。"
    },
    %{
      rank: "expert",
      position: 2,
      name: "PMM(プロダクトマーケティングマネージャー)",
      description: "マーケティング・セールス・カスタマーサクセスなどプロダクトの販売面にかかわる幅広い分野に責任を持ち、取りまとめを行うのがPMMです。"
    },
    %{
      rank: "advanced",
      position: 1,
      name: "デジタルマーケッター",
      description: "デジタル領域のマーケッター"
    },
    %{
      rank: "advanced",
      position: 2,
      name: "D2Cマーケッター",
      description: "世界観・ファンコミュニティの構築を行う"
    },
    %{
      rank: "advanced",
      position: 3,
      name: "メディアプランナー",
      description: "デジタルとオフラインの統合設計・メディアミックス戦略立案を行う"
    },
    %{
      rank: "advanced",
      position: 4,
      name: "データアナリスト",
      description: "データ分析を統計手法・AIを駆使して行う"
    },
    %{
      rank: "basic",
      position: 1,
      name: "デジタル広告プランナー",
      description: "デジタル広告のプランニングを行う"
    },
    %{
      rank: "basic",
      position: 2,
      name: "Web広告マーケッター",
      description: "Web広告でのマーケティングを行う"
    },
    %{
      rank: "basic",
      position: 3,
      name: "Webライター",
      description: "Webライティングを行う"
    },
    %{
      rank: "basic",
      position: 4,
      name: "SNSマーケッター",
      description: "SNSでマーケティングを粉う"
    },
    %{
      rank: "basic",
      position: 5,
      name: "オウンドメディアマーケッター",
      description: "オウンドメディアでマーケティングを行う"
    },
    %{
      rank: "basic",
      position: 6,
      name: "カスタマーサクセスリーダー",
      description: "顧客データ収集・分析を行う"
    },
    %{
      rank: "basic",
      position: 7,
      name: "コミュニティマネージャ",
      description: "コミュニティ設計・運用を行う"
    },
    %{
      rank: "basic",
      position: 8,
      name: "オフラインメディアプランナー",
      description: "広告企画、メディア会社管理を行う"
    },
    %{
      rank: "basic",
      position: 9,
      name: "エントリーアナリスト",
      description: "市場・競合分析を行う"
    },
    %{
      rank: "basic",
      position: 10,
      name: "データサイエンティストR",
      description: "データ分析基盤を一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。"
    }
  ]

  def delete() do
    [CareerWantJob, CareerFieldJob, JobSkillPanel, Job]
    |> Enum.each(fn s ->
      s
      |> Repo.all()
      |> Enum.each(&Repo.delete(&1))
    end)
  end

  def insert() do
    CareerFields.list_career_fields()
    |> Enum.each(fn c ->
      case c.name_en do
        "engineer" -> create_job(@engineer, c)
        "infra" -> create_job(@infra, c)
        "designer" -> create_job(@designer, c)
        "marketer" -> create_job(@marketer, c)
      end
    end)
  end

  def create_job(job_list, career_field) do
    skill_panels =
      SkillPanels.list_skill_panels()
      |> Enum.filter(&String.match?(&1.name, ~r/#{career_field.name_ja}/))

    Enum.each(job_list, fn params ->
      {:ok, job} = Jobs.create_job(params)
      CareerFields.create_career_field_job(%{job_id: job.id, career_field_id: career_field.id})

      case params.rank do
        "basic" ->
          rand_insert(job, skill_panels, 1)

        "advanced" ->
          rand_insert(job, skill_panels, 2)

        "expert" ->
          rand_insert(job, skill_panels, 3)
      end
    end)
  end

  def rand_insert(job, list, num) do
    list
    |> Enum.take_random(num)
    |> Enum.each(fn panel ->
      Jobs.create_job_skill_panel(%{
        job_id: job.id,
        skill_panel_id: panel.id
      })
    end)
  end
end
