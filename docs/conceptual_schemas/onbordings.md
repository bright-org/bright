# オンボーディングに関わるテーブル定義案

### テーブル定義案

- `id`, `inserted_at`, `updated_at` は省略
- 新しく定義したいテーブル
  - `wants`、`want_careers`、`careers`、`user_skill_panels` の4テーブル
- 既に定義案があるテーブル
  - `skill_panels`、`user_skill_panels`、`skill_panels`、`skill_classes`、`skill_class_units`
  - [概念データモデル スキル体系](https://github.com/bright-org/bright/blob/develop/docs/conceptual_schemas/skills.md) にて定義済み

```mermaid
erDiagram
  wants ||--|{ want_careers : ""
  want_careers ||--|{ careers : ""
  careers ||--|{ career_skill_panels : ""
  career_skill_panels ||--|{ skill_panels : ""
  user_skill_panels ||--|{ skill_panels : ""
  skill_panels ||--|{ skill_classes : ""
  skill_classes ||--|{ skill_class_units : ""
  skill_class_units }|--|| skill_units : ""

  wants {
    string want "やりたいことや興味、関心があること"
  }

  want_careers {
    id want_id FK
    id career_id FK
  }

  careers {
    string career "キャリアフィールド"
  }

  career_skill_panels {
    id career_id FK
    id skill_panel_id FK
  }

  skill_panels {
    date locked_date "固定した日"
    string name "スキルパネル名"
  }

  user_skill_panels {
    id user_id FK
    id skill_panel_id FK
  }

  skill_classes {
    id skill_panel_id FK
    string name "クラス名"
  }

  skill_class_units {
    id skill_class_id FK
    id skill_unit_id FK
    int position
  }

  skill_units {
    string name "スキルユニット（大分類）名"
  }

```