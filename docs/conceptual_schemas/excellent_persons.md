## 優秀なエンジニア紹介　ER図
```mermaid
erDiagram
  "優秀なエンジニア紹介" ||--|| "Brightユーザー" : "紹介ユーザー"
  "優秀なエンジニア紹介" ||--|| "Brightユーザー" : "推しユーザー"
  "優秀なエンジニア紹介" ||--|| "チーム" : ""
``````

### 優秀なエンジニア紹介 テーブル
```mermaid
erDiagram
  "excellent_persons" ||--|| "users" : "紹介ユーザー"
  "excellent_persons" ||--|| "users" : "推しユーザー"
  "excellent_persons" ||--|| "teams" : ""


  excellent_persons {
    id introducer_user_id	FK "紹介者ユーザーID"
    id fave_user_id	FK "推しユーザーID"
    id team_id "チームID index"
    text fave_point	"推しポイント"
  }
```
