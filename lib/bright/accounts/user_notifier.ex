defmodule Bright.Accounts.UserNotifier do
  @moduledoc """
  Bright ユーザーに対するメール通知を扱う
  """
  import Swoosh.Email

  use BrightWeb, :verified_routes

  alias Bright.Mailer
  alias Bright.Accounts

  @signature """
  ──────────────────−--- -- - - - - -- ---−──────────────────
  Bright https://bright-fun.org
  エンジニアやPM、UX・UIデザイナーのスキルを見える化
  【カスタマーサクセス連絡先】customer-success@bright-fun.org

  運営会社：株式会社 DigiDockConsulting
  〒802-0001 福岡県北九州市小倉北区浅野3-8-1 AIMビル6階
  ──────────────────−--- -- - - - - -- ---−──────────────────
  """

  @email_from {"Brightカスタマーサクセス", "agent@bright-fun.org"}

  # SendGrid で1リクエストで一括送信可能な最大のメール件数は 1000 件
  # NOTE: https://sendgrid.kke.co.jp/docs/API_Reference/Web_API_v3/Mail/index.html?_gl=1*1sf2pmz*_ga*MTE5MjM3OTk0OS4xNzA1NzI5Nzc1*_ga_JL4V7PSVHH*MTcwNTcyOTc3NC4xLjEuMTcwNTcyOTk2My4wLjAuMA..*_ga_NFRNW0FC62*MTcwNTcyOTc3NC4xLjEuMTcwNTcyOTk2My4wLjAuMA..#-Limitations
  defp max_deliver_size, do: Application.get_env(:bright, :max_deliver_size, 1_000)

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from(@email_from)
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp deliver_many!(recipients, subject, body) do
    Enum.chunk_every(recipients, max_deliver_size())
    |> Enum.each(fn emails_chunk ->
      personalizations = emails_chunk |> Enum.map(&%{to: %{email: &1}})

      new()
      |> put_provider_option(:personalizations, personalizations)
      |> from(@email_from)
      |> subject(subject)
      |> text_body(body)
      |> Mailer.deliver!()
    end)
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "【Bright】ユーザー本登録を完了させ、Bright をお楽しみください（4 日以内有効）", """
    #{user.name}さん
    Brightカスタマーサクセスです。

    Bright ユーザーの仮登録が完了しました。
    下記 URL をクリックいただき、Bright ユーザー本登録を完了させてください。
    URL は、本メール到着から 4 日以内まで有効です。
    #{url}

    Bright ユーザー本登録後は、下記がご利用可能となります。

    ①スキルを選ぶ … 最初に攻略するスキルを選ぶ
    　#{url(~p"/onboardings")}

    ②スキルパネル … エンジニア／デザイナー／マーケッターのスキルチェックと学習、試験
    　#{url(~p"/panels")}
    　スキル入力や学んだ内容のメモ、教材起動、スキル試験ができます。

    ③成長パネル … スキルの成長をグラフと宝石で見れる
    　#{url(~p"/graphs")}
    　スキルの成長を3ヶ月ごとに宝石のような「スキルジェム」で見れます。

    ④スキル検索 … スキル保有者の検索
    　#{url(~p"/searches")}
    　スキルや求職条件からエンジニア／デザイナー／マーケッターを検索できます。
      ※βリリース後にスキル保有者との面談／採用が可能となります（有償）

    ⑤チーム作成 … あらゆる人がチームを作れる
    　#{url(~p"/teams/new")}
    　誰でも「チームの作成」と「チームメンバー招待」ができます。
    　プロジェクトチームだけに限らず、友人同士のチームやコミュニティチームも作れます。

    ⑥チームスキル分析 … チームメンバーのスキル把握を一気にできる
    　#{url(~p"/teams")}
    　所属チームのメンバー全員の「スキルジェム」を一目で見れます。

    ⑦マイページ … 保有スキル／関わっているチーム／ユーザーの確認、各種通知
    　#{url(~p"/mypage")}

    それでは、Bright が織りなす新次元の IT 世界をお楽しみください。

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "【Bright】パスワードリセットを行ってください（24 時間以内有効）", """
    #{user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    パスワードリセットのご依頼をいただきました。
    下記 URL をクリックいただき、パスワードリセットを完了させてください。
    URL は、本メール到着から 24 時間以内まで有効です。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "【Bright】メールアドレス変更を完了させてください（24 時間以内有効）", """
    #{user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    メールアドレス変更のご依頼をいただきました。
    下記 URL をクリックいただき、メールアドレス変更を完了させてください。
    URL は、本メール到着から 24 時間以内まで有効です。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver instructions to add a user sub email.
  """
  def deliver_add_sub_email_instructions(user, email, url) do
    deliver(email, "【Bright】サブメールアドレス追加を完了させてください（24 時間以内有効）", """
    #{user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    サブメールアドレス追加のご依頼をいただきました。
    下記 URL より、サブメールアドレスの追加を確定してください。
    URL は、本メール到着から 24 時間以内まで有効です。
    #{url}
    （サブメールアドレスでは運営からの通知を受け取ることができます。※ ログインには使用できません）

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver two factor auth instructions.
  """
  def deliver_2fa_instructions(user, code) do
    deliver(user.email, "【Bright】2段階認証コード", """
    #{code} が、あなたの Bright 2段階認証コードとなります。
    有効期限は 10 分間です。

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver invitation to team.
  """
  def deliver_invitation_team_instructions(from_user, to_user, team, url) do
    deliver(to_user.email, "【Bright】チームに招待されました（承認URLは 4 日以内有効）", """
    #{to_user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    #{from_user.name} さんから、チーム #{team.name} へ招待されました。

    チームへの招待へ応じる場合は、下記URLをクリックすることで承認してください。
    URL は、本メール到着から 4 日以内まで有効です。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver request team support.
  """
  def deliver_notify_team_support_request(from_user, to_user, team, url) do
    deliver(to_user.email, "【Bright】新しいチーム支援依頼が承認待ちです", """
    #{to_user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    #{from_user.name} さんにからチーム #{team.name} に対する支援依頼が届いています。

    URL から承認待ちの支援依頼をご確認ください。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver accept team support.
  """
  def deliver_accept_team_support_request(from_user, to_user, team) do
    deliver(to_user.email, "【Bright】チーム支援依頼が承認されました", """
    #{to_user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    チーム #{team.name} に対する支援依頼が#{from_user.name} さんにより承認されました。

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver reject team support.
  """
  def deliver_reject_team_support_request(from_user, to_user, team) do
    deliver(to_user.email, "【Bright】チーム支援依頼が非承認となりました", """
    #{to_user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    チーム #{team.name} に対する支援依頼が#{from_user.name} さんにより非承認とされました。

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver interview acceptance.
  """
  def deliver_acceptance_interview_instructions(from_user, to_user, url) do
    deliver(to_user.email, "【Bright】面談参加依頼が届いています", """
    #{to_user.name}さん

    #{from_user.name} さんから、面談の参加依頼が届いています。

    下記URLで面談内容を確認し、面談参加可否を選択してください。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver interview start mail to candidates_user.
  """
  def deliver_start_interview_to_candidates_user(from_user, to_user) do
    deliver(to_user.email, "【Bright】面談が確定されました", """
    #{to_user.name}さん

    #{from_user.name}から、面談が確定されました。

    面談日・ツール・場所は、#{from_user.name}から別途、連絡いたします。

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver interview start mail to recruitor.
  """
  def deliver_start_interview_to_recruiter(from_user, to_user) do
    deliver(from_user.email, "【Bright】面談確定を候補者に連絡しました（調整を行ってください）", """
    #{from_user.name}さん

    以下の文面を#{to_user.name}(#{to_user.email})さんへ送りました。
    別途、日程などをメールで調整してください（Bright内では日程調整は行いません）。

    面談終了後、下記URLで採用調整、選考通知およびチーム招待を行ってください。
    https://採用調整モーダル

    ====================================================================

    #{from_user.name}から、面談が確定されました。

    面談日・ツール・場所は、#{from_user.name}から別途、連絡いたします。

    ====================================================================

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver interview cancel mail to candidates_user.
  """
  def deliver_cancel_interview_to_candidates_user(from_user, to_user) do
    deliver(to_user.email, "【Bright】面談がキャンセルされました", """
    #{to_user.name}さん

    #{from_user.name}から、面談がキャンセルされました。


    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver coordination acceptance.
  """
  def deliver_acceptance_coordination_instructions(from_user, to_user, url) do
    deliver(to_user.email, "【Bright】採用検討依頼が届いています", """
    #{to_user.name}さん

    #{from_user.name} さんから、採用検討の依頼が届いています。

    下記URLで検討内容を確認し、採用可否を選択してください。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver coordination cancel mail to candidates_user.
  """
  def deliver_cancel_coordination_to_candidates_user(from_user, to_user, message) do
    deliver(to_user.email, "【Bright】選考結果のご連絡", """
    #{to_user.name}様

    #{message}

    #{from_user.name}
    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver employment acceptance .
  """
  def deliver_acceptance_employment_instructions(from_user, to_user, url) do
    deliver(to_user.email, "【Bright】採用通知が届いています", """
    #{to_user.name}さん

    #{from_user.name} さんから、採用通知が届いています。

    下記URLで内容を確認し、受諾するか、辞退するかをお答えください。
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver employment accept .
  """
  def deliver_accept_employment_instructions(from_user, to_user, url) do
    deliver(to_user.email, "【Bright】採用が受諾されました", """
    #{to_user.name}さん

    #{from_user.name} さんが採用を受諾しました

    下記URLで内容を確認し、チームジョイン調整を行ってください
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver employment cancel .
  """
  def deliver_cancel_employment_instructions(from_user, to_user) do
    deliver(to_user.email, "【Bright】採用が辞退されました", """
    #{to_user.name}さん

    #{from_user.name} さんが採用を辞退しました

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver team join request .
  """
  def deliver_team_join_request_instructions(from_user, to_user, url) do
    deliver(to_user.email, "【Bright】チームジョイン連携を依頼されました", """
    #{to_user.name}さん

    #{from_user.name} さんがチームジョイン連携を依頼しました

    下記URLで内容を確認し、チームジョイン連携を行ってください
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver free trial apply.
  """
  def deliver_new_message_notification_instructions(to_user, url) do
    deliver(to_user.email, "【Bright】新着メッセージが届いています", """
    #{to_user.name}さん

    採用チャットにメッセージが届いています。

    下記URLからご確認ください
    #{url}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end

  @doc """
  Deliver free trial apply.
  """
  def deliver_free_trial_apply_instructions(from_user, to_user, detail) do
    deliver(to_user.email, "【Bright】無料トライアルの申し込みがありました", """
    以下の内容で無料トライアルが申し込まれました

    ハンドル名: #{from_user.name}
    ユーザーID: #{detail["user_id"]}
    サービス名: #{detail["plan_name"]}
    会社名: #{detail["company_name"]}
    電話番号: #{detail["phone_number"]}
    メールアドレス: #{detail["email"]}
    担当者（本名） #{detail["pic_name"]}
    申込日(JST) #{DateTime.now!("Japan") |> DateTime.truncate(:second) |> DateTime.to_string() |> String.slice(0..18)}
    申込日(UTC) #{DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_string() |> String.slice(0..-2)}

    お得意様であればフォローアップをお願いします
    """)
  end

  @doc """
  Deliver notifications to all confirmed users about sending notification from operation.
  """
  def deliver_operations_notification!() do
    Accounts.list_confirmed_user_emails()
    |> deliver_many!("【Bright】運営からの通知が届きました", """
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    運営からの通知をお届けしました。
    下記 URL をクリックいただき、通知をご確認ください。

    #{url(~p"/notifications/operations")}

    ---------------------------------------------------------------------
    ■本メールにお心当たりのない場合
    ---------------------------------------------------------------------
    お手数ですが、本メールを破棄してください。
    もし気になる点ございましたら、下記までご連絡ください。
    customer-success@bright-fun.org

    #{@signature}
    """)
  end
end
