## 通知テーブル

前提事項

- 通知はどの種類でも共通仕様項目を実装する
- 取得時に共通のルールでデータを取得する為

### 共通項目

```mermaid
erDiagram
  common {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index:（必須ではない）"
    string message	"メッセージ内容"
    text detail	"詳細"
  }
```

## 重要な連絡　 ER 図

```mermaid
erDiagram
  "Brightユーザー" ||--o{ "通知_チーム招待" : ""
  "通知_チーム招待" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_振り返り" : ""

  "Brightユーザー" ||--o{ "通知_採用の調整" : ""
  "通知_採用の調整" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_運営" : ""

```

### 重要な連絡 テーブル

```mermaid
erDiagram
  "users" ||--o{ "notification_team_invitations" : ""
  "notification_team_invitations" ||--|| "users" : ""

  "users" ||--o{ "notification_looking_backs" : ""

  "users" ||--o{ "notification_recruitment_coordinations" : ""
  "notification_recruitment_coordinations" ||--|| "users" : ""

  "users" ||--o{ "notification_operations" : ""

  notification_team_invitations {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    text detail	"詳細"
    string status "ステータス： enum（participation:参加する, abstention:参加しない）"
  }

  notification_looking_backs {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    text detail	"詳細"
  }


  notification_recruitment_coordinations {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string url	"採用の回答するモーダルのURL"
  }

  notification_operations {
    id from_user_id	FK "送信元ユーザー"
    string message	"メッセージ内容"
    text detail	"詳細"
  }

```

## さまざまな人たちとの交流 ER 図

```mermaid
erDiagram
  "Brightユーザー" ||--o{ "通知_スキルアップ" : ""
  "通知_スキルアップ" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_祝福された" : ""
  "通知_祝福された" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_1on1のお誘い" : ""
  "通知_1on1のお誘い" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_推し活" : ""
  "通知_推し活" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_気になる" : ""
  "通知_気になる" ||--|| "Brightユーザー" : ""

  "Brightユーザー" ||--o{ "通知_コミュニティ" : ""
  "通知_コミュニティ" ||--|| "コミュニティ" : ""

  "コミュニティ" ||--|| "ユーザーコミュニティ" : ""

  "ユーザーコミュニティ" ||--o{ "Brightユーザー" : ""

```

## さまざまな人たちとの交流 テーブル

```mermaid
erDiagram
  "users" ||--o{ "notification_improve_skills" : ""
  "notification_improve_skills" ||--|| "users" : ""

  "users" ||--o{ "notification_blesses" : ""
  "notification_blesses" ||--|| "users" : ""

  "users" ||--o{ "notification_1on1_invitations" : ""
  "notification_1on1_invitations" ||--|| "users" : ""

  "users" ||--o{ "notification_faves" : ""
  "notification_faves" ||--|| "users" : ""

  "users" ||--o{ "notification_watches" : ""
  "notification_watches" ||--|| "users" : ""

  "users" ||--o{ "notification_communities" : ""
  "notification_communities" ||--|| "communities" : ""

  "communities" ||--|| "user_communities" : ""

  "user_communities" ||--o{ "users" : ""


  notification_improve_skills {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    string url 	"ジェムのリンクと同じ"
    boolean congratulate　"祝福する"
  }

  notification_blesses {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    text detail	"詳細"
  }

  notification_1on1_invitations {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    text detail	"詳細"
    string accept_status "受入ステータス： enum（acceptance、rejection）"
  }

  notification_faves {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    string url	"エビデンスのURL"
  }

  notification_watches {
    id from_user_id	FK "送信元ユーザー"
    id to_user_id	FK "送信先ユーザー index"
    string message	"メッセージ内容"
    string url	"相手のmypageのURL"
  }

  notification_communities {
    id from_user_id	FK "送信元ユーザー"
    id community_id	FK "対象コミュニティ"
    string message	"メッセージ内容"
    text detail	"詳細"
  }

  communities {
    string name "コミュニティ名"
  }

  user_communities {
    id user_id FK "ユーザーid index"
    id community_id FK "コミュニティid"
    boolean participation_status "参加状況"
  }

```

## 通知と同時に行われる処理

```
重要な連絡
　・チーム招待
　　「参加する」「参加しない」
　　　（チーム招待側の処理でメールを送信しているため制御外）
　・採用の調整　※面談調整の方で別枠化する可能性があるため今は暫定
　　「確認する」
　　　└通知（DB）追加時にメールも送信する
　　　└専用のモーダル（回答するモーダル）
　　　　└詳細は不要
　　　└URL
　・スキルパネル更新
　　「内容を見る」
　　　└通知（DB）追加時にメールも送信する（「成長グラフを見る」をナビゲーションを案内）
　・運営　※CRUD API
　　「内容を見る」
　　　└通知（DB）追加時にメールも送信する
　　　※「デイリー」「ウイークリー」もこのタブに含む

さまざまな人たちとの交流
　・スキルアップ ※スキルアップの方で別枠化する可能性があるため今は暫定
　　「スキルを確認」「祝福する」
        ｜　　　　　　　└　相手の祝福されたテーブルに追加
　　　　└ジェムのリンクと同じ
　・祝福された
　　「内容を見る」（テーブルを作る　共通と同じ）
　・1on1のお誘い
　　「受ける」「断る」
　　　└通知（DB）追加時にメールも送信する
　・推し活
　　「確認する」
　　　└エビデンスに飛ぶ
　　　└URL
　・気になる
　　「相手を見る」
　　　└URL（詳細不要）
　・コミュニティ　※CRUD API
　　「内容を見る」　ラベル：「参加中」「未参加」
　　　　└「参加する」「脱退する」のトグル
          └該当ユーザーのuser_communitiesがない場合は 「未参加」扱い
          └「参加する」をクリック時にuser_communitiesがない場合はレコードを作成
          └「脱退」をクリック時にuser_communitiesの参加状況はfalseに変更
　　　　└通知（DB）追加時にメールも送信する
　　　　└運営側のチームのDBにも追加
　　　　
```
