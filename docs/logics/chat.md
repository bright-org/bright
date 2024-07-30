# 面談チャットの表示仕様


# フィルター仕様

|フィルター名|テーブル名|ステータス|
|--------------|--------|--------- |
|（条件を選択してください）|Interview & Coordination|Interview(waiting_decision, consume_interview, ongoing_interview, one_on_one) & Coordination(waiting_recruit_decision以外)|
|面談打診中|Interview|waiting_decision|
|面談確定待ち|Interview|consume_interview|
|面談確定|Interview|ongoing_interview|
|面談キャンセル|Interview|cancel_interview|
|選考中|Coordination|waiting_recruit_decision|
| （すべて）|Interview & Coordination|Interview(waiting_decision, consume_interview, dismiss_interview,ongoing_interview,cancel_interview, one_on_one) & Coordination(すべて)|



  

