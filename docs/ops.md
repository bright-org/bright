# 運用設計


## Sentryによる障害検知

### ログ通知抑制方法

  - 「SentryのWeb画面」のForeverを指定する 
  - 「elixirでFilterモジュールを実装」

### 既存障害検知と状況
  - CaseClauseError: no case clause matching: %Phoenix.LiveView.Route{}
    - 対応状況: 「SentryのWeb画面」のForeverを指定する
    - 理由: phoenix_live_viewのバージョンを上げれば直る可能があり様子を見ている為Foreverを指定する
  
  - MatchError Tzdata.DataLoader.download_new/1 
    - 対応状況: 抑制設定をしない
    - 理由:tzdata-latest.tar.gzのダウンロードに失敗発生頻度がほぼ無いため
