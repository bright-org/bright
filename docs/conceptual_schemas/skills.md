# 概念データモデル

[12-Bright要件定義書②機能要件（概念データ構造、ジョブ階層）](https://docs.google.com/spreadsheets/d/1-MhX-jKPiplTCU3QrPsLUhzutxiXfkbVxwLA0wImA9s/edit#gid=1018705294)をもとに概念データモデルどうしの関係を図式化

## スキル体系

スキルに関する概念を扱う

### 関係するシート

- 1.Brightユーザー
- 3.スキルパネル
- 6.気になるスキル
- 10.評価対象のスキル

### ER図

```mermaid
erDiagram
  "スキルパネル" ||--|{ "クラス" : ""
  "クラス" }|--|{ "大分類／中分類（スキルユニット）" : ""
  "大分類／中分類（スキルユニット）" ||--|{ "小分類（スキル）" : ""
  "ジャンル" }o--o{ "スキルパネル" : ""
  "Brightユーザー" }o--o{ "スキルパネル" : "気になる"
  "Brightユーザー" ||--o{ "評価データ（スキルスコア）" : ""
  "評価データ（スキルスコア）" ||--|| "クラス" : ""
  "評価データ（スキルスコア）" ||--|{ "スキルスコア詳細" : ""
  "スキルスコア詳細" ||--||  "小分類（スキル）" : "評価する（＝○×△を付ける）"
```

### 補足

- スキルパネルは3ヶ月に1回見直される → 履歴を持つことになる
- スキルユニットは複数のスキルパネルで共有される場合がある
- スキルの評価（スコアリング）はクラスごとに行う ※スキルパネルごとではない

### テーブル定義案

- `id`, `inserted_at`, `updated_at` は省略

```mermaid
erDiagram
  skill_panels ||--|{ skill_classes : ""
  skill_classes ||--|{ skill_class_units : ""
  skill_class_units }|--|| skill_units : ""
  skill_units ||--|{ skill_subunit : ""
  skill_subunit ||--|{ skills : ""
  genres ||--o{ skill_panel_genres : ""
  skill_panel_genres }o--|| skill_panels : ""
  users ||--o{ user_skill_panels : "気になる"
  user_skill_panels }o--|| skill_panels : "気になる"
  users ||--o{ skill_scores : ""
  skill_scores ||--|| skill_classes : ""
  skill_scores ||--|{ skill_score_items : ""
  skill_score_items ||--|| skills : ""

  skill_panels {
    string version "バージョン"
    string name "スキルパネル名"
  }

  skill_classes {
    int skill_panel_id FK
    string name "クラス名"
  }

  skill_class_units {
    int skill_class_id FK
    int skill_unit_id FK
  }

  skill_units {
    string name "スキルユニット（大分類）名"
  }

  skill_subunit {
    int skill_unit_id FK
    string name "スキルユニット（中分類）名"
  }

  skills {
    int skill_subunit_id FK
    string name "スキル（小分類）名"
  }

  genres {
    string name "ジャンル名"
  }

  skill_panel_genres {
    int skill_panel_id FK
    int genre_id FK
  }

  users {
    string username UK "ハンドルネーム"
  }

  user_skill_panels {
    int user_id FK
    int skill_panel_id FK
  }

  skill_scores {
    int user_id FK
    int skill_panel_id FK
  }

  skill_score_items {
    int skill_score_id FK
    int skill_id FK
    int score "enum（0: ×、1: △、2: ○）"
  }
```
