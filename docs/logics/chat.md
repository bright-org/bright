# 面談チャットの表示仕様


## フィルター仕様

|フィルター名|テーブル名|ステータス|
|--------------|--------|--------- |
|（条件を選択してください）|Interview & Coordination|Interview(waiting_decision, consume_interview, ongoing_interview, one_on_one) & Coordination(waiting_recruit_decision以外)|
|面談打診中|Interview|waiting_decision|
|面談確定待ち|Interview|consume_interview|
|面談確定|Interview|ongoing_interview|
|面談キャンセル|Interview|cancel_interview|
|選考中|Coordination|waiting_recruit_decision|
| （すべて）|Interview & Coordination & Employment|Interview(waiting_decision, consume_interview, dismiss_interview,ongoing_interview,cancel_interview, one_on_one) & Coordination(すべて) & Employment(すべて)|


## Chatテーブルのリンクルール

上からパターンマッチをして該当時にリンク

|条件|リンクするテーブル|
|----|------------------|
|relation_coordination_id == nil and relation_employment_id == nil|Interview|
|relation_employment_id == nil|Coordination|
|relation_employment_id != nil|Employment|


## Chatテーブルマイグレーションルール
上記「フィルター仕様」を実現するために、予めChatをマイグレーションする必要がある


テーブルリンクは
### before

|項目名|格納内容|
|-------|--------|
|relation_id|Interview.id|


ChatはInterviewのみがリンク

### after

|項目名|格納内容|
|-------|--------|
|relation_id|Interview.id|
|relation_coordination_id|Coordination.id|
|relation_employment_id|Employment.id|

ChatはInterview、Coordination、Employmentをリンク


### 詳細設定条件

#### relation_coordination_idをセットする条件

* Interview.status = :completed_interview
* Interview.recruiter_user_id = Coordination.recruiter_user_id
* Interview.updated_at <= Coordination.inserted_at <= Interview.updated_at + 10 sec

#### relation_employment_idをセットする条件

* Coordination.status = :completed_coordination
* Coordination.recruiter_user_id = Employment.recruiter_user_id
* Coordination.updated_at <= Employment.inserted_at <= Coordination.updated_at + 10 sec

