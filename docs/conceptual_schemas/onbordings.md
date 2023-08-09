# オンボーディングに関わるテーブル定義
[行動シナリオ「4. オンボーディングで最初のスキルパネルを選択する」](https://docs.google.com/spreadsheets/d/161ai6d8-26adTub9nlOtpVAfTmPt9NQp4--q68G0WZo/edit#gid=458681671)で必要なテーブルの定義案です。

[figma](https://www.figma.com/file/q9SVY4YWjijOrgsQtJjlD6/Bright?type=design&node-id=627-3632&mode=design&t=aO8asUN6kiZ0xGCq-0) の対象画面は
4-1-1、4-1-2、4-1-3、4-1-4までを範囲にしています。

### テーブル定義案

- `id`, `inserted_at`, `updated_at` は省略
- 新しく定義したいテーブル
  - `career_wants`、`career_want_jobs`、`career_fields`、`jobs`、`job_skill_panels`、`user_onboardings` の6テーブル
- 既に定義案があるテーブル
  - `skill_panels`、`user_skill_panels`、`skill_panels`、`skill_classes`、`skill_class_units`
  - [概念データモデル スキル体系](https://github.com/bright-org/bright/blob/develop/docs/conceptual_schemas/skills.md) にて定義済み

- `career_want_jobs` は、jobsからcareer_fieldsを逆引きするために使う。複数同じcareer_fieldが引けた場合はユニーク化する。
- `job_skill_panels` はjobsかskill_panelを逆引きするために使う。複数同じskill_panelが引けた場合はユニーク化する。
- オンボーディングではskill_panelsを参照する際、skill_classes.class=1で引く前提。
- `user_onboardings` はオンボーディング初回のみ登録される。userとは1:1になる。
- user_onboardings.skill_panel_idは、マーケティング用途等でオンボーディング時にユーザーがどのスキルパネルを選択したか参照できるためのカラム。

```mermaid
erDiagram
  career_wants ||--|{ career_want_jobs : ""
  career_want_jobs ||--|{ jobs : ""
  jobs }|--|| career_fields : ""
  jobs ||--|{ job_skill_panels : ""
  job_skill_panels ||--|{ skill_panels : ""
  user_skill_panels ||--|{ skill_panels : ""
  user_skill_panels }o--|| users : ""
  user_onboardings ||--|| users : ""
  skill_panels ||--|{ skill_classes : ""
  skill_classes ||--|{ skill_class_units : ""
  skill_class_units }|--|| skill_units : ""

  user_onboardings {
    id user_id FK
    datetime completed_at "オンボーディング完了日"
    int skill_panel_id FK
  }

  career_wants {
    string name "やりたいことや興味、関心があること"
    int position "表示順"
  }

  career_want_jobs {
    id want_id FK
    id job_id FK
  }

  career_fields {
    string name_en "キャリアフィールド名(英語)"
    string name_ja "キャリアフィールド名(日本語)"
    int position "表示順"
  }

  jobs {
    id careerfield_id FK
    string name "ジョブ名"
    int position
  }

  job_skill_panels {
    id job_id FK
    id skill_panel_id FK
  }

  skill_panels {
    date locked_date "固定した日"
    string name "スキルパネル名"
  }
```
