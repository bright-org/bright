# 概念データモデル

ユーザーとスキルまわり（教材・試験・エビデンス登録）の概念データモデルです。

参考：

- [行動シナリオ：教材・試験・エビデンス登録](https://docs.google.com/spreadsheets/d/161ai6d8-26adTub9nlOtpVAfTmPt9NQp4--q68G0WZo/edit#gid=496055998)

## ER図

```mermaid
erDiagram
  "Brightユーザー" ||--o{ "スキルスコア" : ""
  "スキルスコア" ||--|{ "スキルスコア詳細" : ""
  "スキルスコア詳細" ||--||  "スキル" : "◯△－を付ける"

  "スキル" ||--o| "スキル教材" : ""
  "スキル" ||--o| "スキル試験" : ""

  "Brightユーザー" ||--o{ "スキル試験結果" : ""
  "スキル試験結果" ||--|| "スキル" : "試験する"
  "スキル試験結果" ||--|| "スキル試験" : ""
  "Brightユーザー" ||--o{ "スキル教材閲覧有無" : "閲覧する"
  "スキル教材閲覧有無" ||--|| "スキル" : ""
  "スキル教材閲覧有無" ||--|| "スキル教材" : ""
  "Brightユーザー" ||--o{ "エビデンス" : ""
  "エビデンス" ||--|| "スキル" : "WIP・ヘルプ・完了する"
  "エビデンス" ||--|{ "エビデンス投稿" : "投稿する"
  "エビデンス投稿" }|--|| "Brightユーザー" : "（投稿主）"
  "エビデンス投稿" ||--|{ "添付画像" : "アップロード"
  "エビデンス投稿" ||--|{ "リアクション" : "いいね"
  "リアクション" }|--|| "Brightユーザー" : "（リアクション主）"
```

### 補足

- エビデンス投稿への添付画像はエビデンスと作成・削除を同一で行うため共通テーブル
- [スキル、スキルスコア系は別ファイルにあります](./skills.md)


### テーブル定義案


```mermaid
erDiagram
  skill_scores ||--|| skills : ""
  skills ||--|| skill_evidences : ""
  skills ||--|| skill_exams : ""
  skills ||--|| skill_references : ""

  users ||--o{ skill_scores : ""
  users ||--o{ skill_evidences : ""
  users ||--o{ skill_evidence_posts : "投稿"
  skill_evidences ||--o{ skill_evidence_posts : ""

  users {
  }

  skills {
    id skill_categories_id FK
    string name "スキル（小分類）名"
    int position
  }

  skill_exams {
    id skill_id FK
    string url
  }

  skill_references {
    id skill_id FK
    string url
  }

  skill_scores {
    id user_id FK
    id skill_id FK
    string score "enum（low=－、middle=△、high=◯）"
    string exam_progress "enum（wip、done）"
    boolean reference_read
    boolean evidence_filled
  }

  skill_evidences {
    id skill_id FK
    id user_id FK
    string progress "enum（wip、help、done）"
  }

  skill_evidence_posts {
    id skill_id FK
    id user_id FK
    string content
    list image_paths
  }
```

備考

- 下記のデータをskill_scoresに保持する
  - スキル試験結果
  - スキル教材閲覧有無
  - エビデンスを一度でも入れたかどうか
    - ※wip/help/doneの詳細ステータスはskill_evidencesがもつ

