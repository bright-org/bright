# 決済

## テーブル設計

### user_stripe_customers テーブル

- Stripe の顧客 ID 情報を保存するテーブルを新設する。

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

- Bright の契約テーブルに Stripe のサブスクリプション ID を保存する項目を追加する。Stripe サブスクリプション ID は解約時に必要となる。

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

### subscription_plans テーブルと stripe_prices テーブル

- Bright のプランを保存する subscription_plans テーブルに Stripe の商品 ID を保存する項目を追加する。
- Stripe の価格情報を保存するために stripe_prices テーブルを新設する。Stripe Checkout セッション開始時に利用する。

```mermaid
erDiagram
subscription_plans {
    uuid id PK "プランID"
    varchar plan_code "プランコード"
    varchar name_jp "プラン名"
    int create_teams_limit "チーム上限数"
    int create_enable_hr_functions_teams_limit "育成チーム上限数"
    int team_members_limit "チーム所属上限人数"
    timestamp available_contract_end_datetime ""
    int free_trial_priority "無料トライアル優先度"
    timestamp inserted_at "登録日時"
    timestamp updated_at "更新日時"
    int authorization_priority ""
    varchar stripe_product_id "Stripe商品ID（Stripe連携時追加項目）"
}

stripe_prices {
    uuid id PK "ID"
    varchar stripe_price_id "Stripe価格ID"
    varchar subscription_plan_id "サブスクリプションプランID:subscription_plans.id"
    varchar stripe_lookup_key "Stripe価格lookupキー"
    timestamp inserted_at "登録日時"
    timestamp updated_at "更新日時"
}

subscription_plans ||--o{ stripe_prices : "has many"
```

### stripe_customer_portal_configurations テーブル

- Stripe のカスタマーポータルを開く際に機能を限定するために利用する ConfigurationID を保存するためのテーブルを新設する。

```mermaid
erDiagram
stripe_customer_portal_configurations {
    uuid id PK "ID"
    varchar configuration_id "Configuration ID"
    varchar lookup_key "Stripe側のConfigurationのmetaにlookup_keyを用意して対応させるための項目"
    timestamp inserted_at "登録日時"
    timestamp updated_at "更新日時"
}
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
    Stripe ->> Bright: Checkoutセッション返却
    Bright ->> Stripe: Checkoutセッションのレスポンスに含まれるURLにリダイレクト

    Stripe ->> User: 支払い方法選択・入力画面を表示
    User ->> Stripe: 支払い方法を入力し購入完了
    Stripe ->> Bright: 購入完了ページへリダイレクト
    alt subscription_user_plansテーブルに契約情報が登録されていない場合
        Bright ->> Bright: subscription_user_plansテーブルに契約情報とユーザを登録
        Bright ->> User: 購入完了画面を表示
        Bright ->> User: 購入完了メールを通知
    else
        Bright ->> User: 購入完了画面を表示
    end
    Stripe ->> Bright: 購入完了通知
    alt subscription_user_plansテーブルに契約情報が登録されていない場合
        Bright ->> Bright: subscription_user_plansテーブルに契約情報とユーザを登録
        Bright ->> User: 購入完了メールを通知
    end
```

## 解約処理

```mermaid
sequenceDiagram
    participant User
    participant Bright
    participant Stripe

    User ->> Bright: 解約ボタン押下
    Bright ->> Bright: stripe_customer_portal_configurationsテーブルからcancel用のConfigurationを取得
    alt cancel用のConfigurationが存在しない場合
        Bright ->> Stripe: Portal Configuration作成API実行(cancelのみ許可)
        Stripe ->> Bright: Configuration Object返却
        Bright ->> Bright: stripe_customer_portal_configurationsテーブルにConfigurationを保存
    end

    Bright ->> Stripe: Customer Portal SessionAPI実行(cancel用configurationId指定)
    Stripe ->> Bright: Customer Portal SessionAPIレスポンス返却
    Bright ->> Stripe: APIレスポンスのURLにリダイレクト
    Stripe ->> User: 解約のみのCustomer Portal表示
    User ->> Stripe: 解約ボタン押下
    Stripe ->> Bright: mypageに戻る
    Stripe ->> Bright: 解約成功通知

    Bright ->> Bright: subscription_user_plansテーブルを契約終了状態に更新
    Bright ->> User: 解約完了メールを通知
```

## 支払い方法変更処理(クレカ変更)

```mermaid
sequenceDiagram
    participant User
    participant Bright
    participant Stripe

    User ->> Bright: 支払い方法変更ボタン押下
    Bright ->> Bright: stripe_customer_portal_configurationsテーブルからpayment_method_update用のConfigurationを取得
    alt payment_method_update用のConfigurationが存在しない場合
        Bright ->> Stripe: Portal Configuration作成API実行(payment_method_updateのみ許可)
        Stripe ->> Bright: Configuration Object返却
        Bright ->> Bright: stripe_customer_portal_configurationsテーブルにConfigurationを保存
    end

    Bright ->> Stripe: Customer Portal SessionAPI実行(payment_method_update用configurationId指定)
    Stripe ->> Bright: Customer Portal SessionAPIレスポンス返却
    Bright ->> Stripe: APIレスポンスのURLにリダイレクト
    Stripe ->> User: 支払い方法変更のみのCustomer Portal表示
    User ->> Stripe: 支払い方法変更
    Stripe ->> Bright: mypageに戻る
```

## プラン変更処理

### 無料トライアルプランから無料トライアルプランへの変更

既存の無料トライアル申込の流れと同様のため割愛する
※とはいえ、後で既存の流れを確認した上で追記しておきたい

### 無料トライアルプランから課金プランへの変更

購入処理の流れと同様
※とはいえ、後で既存の流れを確認した上で追記しておきたい

無料トライアルの終了日時を入れるべきか？
ただし、現状無料トライアル申込中に上位プランの無料トライアルを申し込んでも下位プランの終了日時は入らない

### 課金プランから無料トライアルプランへの変更

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
    User ->> Bright: 開始ボタン押下
    Bright ->> Stripe: Stripe 解約API実行
    Stripe ->> Bright: 解約成功
    Bright ->> User: 解約メールを通知
    Bright ->> Bright: subscription_user_plansテーブルに契約情報とユーザを登録
    Bright ->> User: プラン変更完了画面を表示
    Bright ->> User: 無料トライアル申込完了メール(現状送られていない？)
```

### 課金プランから課金プランへの変更

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
    User ->> Bright: プラン変更ボタン押下
    Bright ->> Bright: stripe_customer_portal_configurationsテーブルからupdate用のConfigurationを取得
    alt update用のConfigurationが存在しない場合
        Bright ->> Stripe: Portal Configuration作成API実行(subscription update, payment update許可)
        Stripe ->> Bright: Configuration Object返却
        Bright ->> Bright: stripe_customer_portal_configurationsテーブルにConfigurationを保存
    end
    Bright ->> Stripe: Customer Portal SessionAPI実行(update用configurationId指定)
    Stripe ->> Bright: Customer Portal SessionAPIレスポンス返却
    Bright ->> Stripe: APIレスポンスのURLにリダイレクト
    Stripe ->> User: プラン変更のCustomer Portal表示
    User ->> Stripe: プラン変更および支払い方法を入力し購入完了
    Stripe ->> Bright: プラン変更完了通知
    Bright ->> Bright: subscription_user_plansテーブルに契約情報とユーザを登録
    Bright ->> User: プラン変更完了画面を表示
    Bright ->> User: 変更前プランの解約メールを通知
    Bright ->> User: 変更後プランの購入完了メールを通知
```

## 支払い履歴

```mermaid
sequenceDiagram
    participant User
    participant Bright
    participant Stripe

    User ->> Bright: お支払い履歴の確認ボタン押下
    Bright ->> Bright: invoice用のConfigurationを取得
    alt invoice用のConfigurationが存在しない場合
        Bright ->> Stripe: Portal Configuration作成API実行(invoiceのみ許可)
        Stripe ->> Bright: Configuration Object返却
        Bright ->> Bright: Configurationを保存
    end
    Bright ->> Stripe: Customer Portal SessionAPI実行(invoice用configurationId指定)
    Stripe ->> Bright: Customer Portal SessionAPIレスポンス返却
    Bright ->> Stripe: APIレスポンスのURLにリダイレクト
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
    Bright ->> User: プラン解約メールを通知
```
