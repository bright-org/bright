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


## Chatデータ変換仕様
上記「フィルター仕様」を実現するために、予めChatデータを変換する必要がある

変換ルールを「Chatデータ変換仕様」として定義する

### before

ChatはInterviewのみがリンク

### after

Chatはrelation_typeによってInterview、Coordination、Employmentをリンク

|Chat.relation_type|条件|
|--------------|--------|
|interview|Interview.status != :completed_interview|
|coordination|Coordination.status != :completed_coordination|
|employment|Coordination.status = :completed_coordination|

### 詳細変換条件

#### Chat.relation_type = :coordination, relation_id = Chat.Coordination.id に変換条件

* Interview.status = :completed_interview
* Interview.recruiter_user_id = Coordination.recruiter_user_id
* Interview.updated_at = Coordination.inserted_at (1秒でもずれるとヒットしないため別途対策は必要)

#### Chat.relation_type = :employment, relation_id = Chat.Employment.id に変換条件

* Coordination.status = :completed_coordination
* Coordination.recruiter_user_id = Employment.recruiter_user_id
* Coordination.updated_at = Employment.inserted_at (1秒でもずれるとヒットしないため別途対策は必要)

