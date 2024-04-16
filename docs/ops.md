# 運用設計

## 1.運用想定

- Sentryでのログ通知抑制
  - 方法
    - 「SentryのWeb画面」のForeverを指定する
    - 「elixirでFilterモジュールを実装」
  - 抑制設定済み項目
    - CaseClauseError: no case clause matching: %Phoenix.LiveView.Route{}
      - 理由: phoenix_live_viewのバージョンを上げれば直る可能があり様子を見ている為Foreverを指定する
  - 抑制設定をしない項目
    - MatchError Tzdata.DataLoader.download_new/1 
      - 理由:tzdata-latest.tar.gzのダウンロードに失敗発生頻度がほぼ無いため
