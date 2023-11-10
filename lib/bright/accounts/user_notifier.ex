defmodule Bright.Accounts.UserNotifier do
  @moduledoc """
  Bright ユーザーに対するメール通知を扱う
  """
  import Swoosh.Email

  use BrightWeb, :verified_routes

  alias Bright.Mailer

  @signature """
  ──────────────────−--- -- - - - - -- ---−──────────────────
  Bright https://bright-fun.org
  エンジニアやPM、UX・UIデザイナーのスキルを見える化
  【カスタマーサクセス連絡先】customer-success@bright-fun.org

  運営会社：株式会社 DigiDockConsulting
  〒802-0001 福岡県北九州市小倉北区浅野3-8-1 AIMビル6階
  ──────────────────−--- -- - - - - -- ---−──────────────────
  """

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Brightカスタマーサクセス", "customer-success@bright-fun.org"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "【Bright】ユーザー本登録を完了させ、Bright をお楽しみください（24 時間以内有効）", """
    #{user.name}さん
    Brightカスタマーサクセスです。

    Bright ユーザーの仮登録が完了しました。
    下記 URL をクリックいただき、Bright ユーザー本登録を完了させてください。
    URL は、本メール到着から 24 時間以内まで有効です。
    #{url}

    Bright ユーザー本登録後は、下記がご利用可能となります。

    ①スキルを選ぶ … 最初に攻略するスキルを選ぶ
    　#{url(~p"/onboardings")}
    　「やりたいこと」か「ジョブ」から最初のスキルをお選びいただけます。

    ②スキルパネル … エンジニア／デザイナー／マーケッターのスキルチェックと学習、試験
    　#{url(~p"/panels")}
    　スキル入力や学んだ内容のメモ、教材起動、スキル試験ができます。

    ③成長グラフ … スキルの成長をグラフと宝石で見れる
    　#{url(~p"/graphs")}
    　スキルの成長を3ヶ月ごとに宝石のような「スキルジェム」で見れます。

    ④スキル検索／スカウト … スキル保有者の検索、スカウト
    　#{url(~p"/searches")}
    　スキルや求職条件からエンジニア／デザイナー／マーケッターを検索できます。
    　※9～10月にはスキル保有者のスカウトもできるようになります（有償）

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
    deliver(to_user.email, "【Bright】チームに招待されました（承認URLは24 時間以内有効）", """
    #{to_user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    #{from_user.name} さんから、チーム #{team.name} へ招待されました。

    チームへの招待へ応じる場合は、下記URLをクリックすることで承認してください。
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
  Deliver interview acceptance .
  """
  def deliver_acceptance_interview_instructions(from_user, to_user, url) do
    deliver(to_user.email, "【Bright】面談調整依頼が届いています", """
    #{to_user.name}さん
    Brightカスタマーサクセスです。

    いつも Bright をご利用いただき、ありがとうございます。

    #{from_user.name} さんから、面談の調整依頼が届いています。

    面談調整を行う場合は、下記URLから面談可否を入力してください。
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

end
