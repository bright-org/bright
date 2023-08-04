# 概念データモデル

[12-Bright要件定義書②機能要件（概念データ構造、ジョブ階層）](https://docs.google.com/spreadsheets/d/1-MhX-jKPiplTCU3QrPsLUhzutxiXfkbVxwLA0wImA9s/edit#gid=1018705294)をもとに概念データモデルどうしの関係を図式化

## スキル体系

スキルに関する概念を扱う

### 関係するシート

- 1.Brightユーザー
- 3.スキルパネル
- 6.気になるスキル
- 9.スキルアップ対象のスキル
- 10.対象のスキルスコア

### ER図

```mermaid
erDiagram
  "キャリアフィールド" ||--|{ "ジョブ" : ""
  "ジョブ" ||--|{ "スキルパネル" : ""
  "スキルパネル" ||--|{ "クラス" : ""
  "クラス" }|--|{ "大分類（ユニット）" : ""
  "大分類（ユニット）" ||--|{ "中分類（カテゴリ）" : ""
  "中分類（カテゴリ）" ||--|{ "小分類（スキル）" : ""
  "Brightユーザー" }o--o{ "スキルパネル" : "気になる"
  "Brightユーザー" ||--o{ "スキルアップ" : "最大5件まで"
  "Brightユーザー" ||--o{ "スキルクラススコア" : ""
  "Brightユーザー" ||--|{ "キャリアフィールドスコア" : ""
  "Brightユーザー" ||--|{ "スキルユニットスコア" : ""
  "キャリアフィールドスコア" }|--|| "キャリアフィールド" : ""
  "スキルアップ" ||--|| "クラス" : ""
  "スキルアップ" ||--|| "大分類（ユニット）" : ""
  "スキルクラススコア" ||--|| "クラス" : ""
  "スキルクラススコア" ||--|{ "スキルスコア" : ""
  "スキルスコア" ||--||  "小分類（スキル）" : "◯△－を付ける"
  "スキルユニットスコア" ||--|| "大分類（ユニット）" : ""
  "スキルユニットスコア" ||--|{ "スキルスコア" : ""
```

### 補足

- スキルパネルは3ヶ月に1回見直される → 履歴を持つことになる
- スキルユニットは複数のスキルパネルで共有される場合がある
- スキルアップはお気に入りのような概念で、「気になる」よりも強い関心を持っているイメージ

### テーブル定義案

- `id`, `inserted_at`, `updated_at` は省略
- スキルパネル更新ロジックに係る情報は省略
- 定義案が別ファイルにあるものを省略

```mermaid
erDiagram
  career_fields ||--|{ jobs : ""
  jobs ||--|{ job_skill_panels : ""
  skill_panels ||--|{ skill_classes : ""
  job_skill_panels ||--|{ skill_panels : ""
  skill_classes ||--|{ skill_class_units : ""
  skill_class_units }|--|| skill_units : ""
  skill_units ||--|{ skill_categories : ""
  skill_categories ||--|{ skills : ""
  users ||--o{ user_skill_panels : "スキルパネルを選ぶ等"
  user_skill_panels }o--|| skill_panels : ""
  users ||--o{ skill_improvements : "スキルアップを登録する"
  skill_improvements ||--|| skill_classes : ""
  skill_improvements ||--|| skill_units : ""
  users ||--o{ skill_class_scores : ""
  users ||--o{ skill_unit_scores : ""
  users ||--|{ career_field_scores : ""
  skill_class_scores ||--|| skill_classes : ""
  skill_class_scores ||--|{ skill_scores : ""
  skill_scores ||--|| skills : ""
  skill_unit_scores ||--|| skill_units : ""
  career_fields ||--|| career_field_scores : ""

  career_fields {
  }

  jobs {
  }

  job_skill_panels {
  }

  skill_panels {
    string name "スキルパネル名"
  }

  skill_classes {
    id skill_panel_id FK
    string name "クラス名"
    int class "クラス（クラス1なら1、クラス２なら２、...が入る）"
  }

  skill_class_units {
    id skill_class_id FK
    id skill_unit_id FK
    int position
  }

  skill_units {
    string name "スキルユニット（大分類）名"
  }

  skill_categories {
    id skill_unit_id FK
    string name "スキルユニット（中分類）名"
    int position
  }

  skills {
    id skill_categories_id FK
    string name "スキル（小分類）名"
    int position
  }

  users {
    string username UK "ハンドルネーム"
  }

  user_skill_panels {
    id user_id FK
    id skill_panel_id FK
  }

  skill_improvements {
    id user_id FK
    id skill_class_id FK
    id skill_unit_id FK
  }

  skill_class_scores {
    id user_id FK
    id skill_class_id FK
    float percentage
    string level
  }

  skill_unit_scores {
    id user_id FK
    id skill_unit_id FK
    float percentage
  }

  skill_scores {
    id skill_class_score_id FK
    id skill_unit_score_id FK
    id skill_id FK
    int score "enum（0: －、1: △、2: ◯）"
  }

  career_field_scores {
    id user_id FK
    id career_field_id FK
    float percentage
    integer high_skills_count
  }
```
