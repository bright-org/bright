# 決済

## テーブル設計

### user_stripe_customers テーブル

- Stripe の顧客 ID 情報を保存する

```mermaid
erDiagram
user_stripe_customers {
    uuid user_id FK "ユーザID:users.id"
    string stripe_customer_id "顧客ID"
    datetime inserted_at "登録日時"
    datetime updated_at "更新日時"
}

users ||--o| user_stripe_customers: contains

```

### subscription_user_plans テーブル

```mermaid
erDiagram
subscription_user_plans {
    uuid id PK "ID"
    uuid user_id FK "ユーザID:users.id"
    uuid subscription_plan_id FK "サブスクリプションプランID:subscription_plans.id"
    string subscription_status "サブスクリプションステータス"
    datetime subscription_start_datetime "サブスクリプション開始日時"
    datetime subscription_end_datetime "サブスクリプション終了日時"
    datetime trial_start_datetime "無料トライアル開始日時"
    datetime trial_end_datetime "無料トライアル終了日時"
    datetime inserted_at "登録日時"
    datetime updated_at "更新日時"
    string company_name "企業名"
    string phone_number "電話番号"
    string pic_name "担当者名"
    string stripe_subscription_id "StripeサブスクリプションID（Stripe連携時追加項目）"
}

users ||--o{ subscription_user_plans: contains
subscription_plans ||--o{ subscription_user_plans: contains
```

### 決済履歴を保存するテーブル

Bright 側に不要とのことで作成しない

## 購入処理

```mermaid
sequenceDiagram
    participant User
    participant BrightLP
    participant Bright
    participant Stripe

    User ->> BrightLP: 料金プランページにアクセス
    BrightLP ->> User: 料金プランページ表示
    User ->> BrightLP: 無料トライアルボタン押下
    BrightLP ->> Bright: 無料トライアルページに遷移
    Bright ->> Bright: user_stripe_customersテーブルにユーザIDとStripe顧客IDを検索・取得
    User ->> Bright: プラン登録ボタン押下
    alt user_stripe_customersにユーザIDが存在する場合
        Bright ->> Stripe: Stripe Checkout セッション開始
    else
        Bright ->> Stripe: 顧客ID作成 API呼び出し (ユーザIDを渡す)
        Stripe ->> Bright: 顧客IDを返す
        Bright ->> Bright: user_stripe_customersテーブルにユーザIDと顧客IDを登録
        Bright ->> Stripe: Stripe Checkout セッション開始
    end
    Stripe ->> User: 支払い方法選択・入力画面を表示
    User ->> Stripe: 支払い方法を入力し購入完了
    Stripe ->> Bright: 購入完了通知
    Bright ->> Bright: subscription_user_plansテーブルに契約情報とユーザを登録
    Bright ->> User: 購入完了画面を表示
    Bright ->> User: 購入完了メールを通知
```

## 解約処理

```mermaid
sequenceDiagram
    participant User
    participant Bright
    participant Stripe

    User ->> Bright: 解約ボタン押下
    Bright ->> Stripe: Stripe 解約API実行
    Stripe ->> Bright: 解約成功通知

    Bright ->> Bright: subscription_user_plansテーブルを契約終了状態に更新
    Bright ->> User: 解約完了メールを通知
```

## プラン変更処理

TODO

## 支払い履歴

```mermaid
sequenceDiagram
    participant User
    participant Bright
    participant Stripe

    User ->> Bright: お支払い履歴の確認ボタン押下
    Bright ->> Stripe: Portal Configuration作成API実行(invoiceのみ許可)
    Stripe ->> Bright: Configuration Object返却
    Bright ->> Stripe: Customer Portal SessionAPI実行(configurationId指定)
    Stripe ->> User: 請求履歴情報のみのCustomer Portal表示
    User ->> User: 請求書確認・PDFダウンロード
```

- [Portal Configuration 作成 API](https://docs.stripe.com/api/customer_portal/configurations/create)

- [Customer Portal SessionAPI](https://docs.stripe.com/api/customer_portal/sessions)

## 継続課金処理

```mermaid
sequenceDiagram
    participant User
    participant Bright
    participant Stripe

    Stripe ->> Bright: 継続課金失敗通知
    Bright ->> Bright: subscription_user_plansテーブルを契約終了状態に更新
    Bright ->> User: プラン解約メール
```
