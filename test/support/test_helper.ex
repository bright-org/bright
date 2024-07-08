defmodule Bright.TestHelper do
  @moduledoc """
  Test helpers.
  """

  import Bright.Factory
  import Plug.Conn
  import Phoenix.ConnTest
  import Swoosh.TestAssertions
  import ExUnit.Assertions

  alias Bright.Accounts
  alias BrightWeb.Endpoint
  alias BrightWeb.UserAuth
  alias Bright.Repo

  @user_2fa_cookie_key "_bright_web_user_2fa_done"

  @test_support_dir __DIR__

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    current_password = "password1"
    user = create_user_with_password(current_password) |> insert_user_relations()
    insert(:user_onboarding, user: user)
    user = user |> Repo.preload([:user_profile, :user_onboardings])
    %{conn: log_in_user(conn, user), user: user, current_password: current_password}
  end

  def register_and_log_in_social_account_user(%{conn: conn}) do
    user = insert(:user_registered_by_social_auth) |> insert_user_relations()
    insert(:user_onboarding, user: user)
    user = user |> Repo.preload([:user_profile, :user_onboardings])
    %{conn: log_in_user(conn, user), user: user}
  end

  def register_and_log_in_user_not_onboarding(%{conn: conn}) do
    user =
      insert(:user) |> insert_user_relations() |> Repo.preload([:user_profile, :user_onboardings])

    %{conn: log_in_user(conn, user), user: user}
  end

  def setup_api_basic_auth(%{conn: conn}) do
    username = Application.get_env(:bright, :api_basic_auth_username)
    password = Application.get_env(:bright, :api_basic_auth_password)

    {:ok,
     conn:
       put_req_header(conn, "authorization", "Basic " <> Base.encode64("#{username}:#{password}"))}
  end

  def insert_user_relations(user) do
    insert(:user_profile, user: user)
    insert(:user_job_profile, user: user)
    user
  end

  def setup_career_fields(_context) do
    career_fields = Bright.Seeds.CareerField.insert()
    %{career_fields: career_fields}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> init_test_session(%{})
    |> put_session(:user_token, token)
  end

  @doc """
  Setup two_factor_auth_done.

  Set cookie and insert user two_factor_auth_done token.
  """
  def set_two_factor_auth_done(conn, user) do
    {token, user_token} = Accounts.UserToken.build_user_token(user, "two_factor_auth_done")

    insert(:user_token, user_token |> Map.from_struct())

    # 署名付き Cookie にしないといけないので以下で生成
    %{value: signed_token} =
      conn
      |> Map.replace!(:secret_key_base, Endpoint.config(:secret_key_base))
      |> UserAuth.write_2fa_auth_done_cookie(token)
      |> fetch_cookies()
      |> Map.fetch!(:resp_cookies)
      |> Map.fetch!(@user_2fa_cookie_key)

    conn
    |> put_req_cookie(@user_2fa_cookie_key, signed_token)
  end

  def assert_confirmation_mail_sent(user_email) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】ユーザー本登録を完了させ、Bright をお楽しみください（4 日以内有効）"
      assert email.to == [{"", user_email}]
      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def assert_reset_password_mail_sent(user) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】パスワードリセットを行ってください（24 時間以内有効）"
      assert email.to == [{"", user.email}]
      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def assert_two_factor_auth_mail_sent(user) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】2段階認証コード"
      assert email.to == [{"", user.email}]
      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def assert_two_factor_auth_mail_sent(user, code) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】2段階認証コード"
      assert email.to == [{"", user.email}]
      assert email.text_body =~ code
      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def assert_update_email_mail_sent(new_email) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】メールアドレス変更を完了させてください（24 時間以内有効）"
      assert email.to == [{"", new_email}]
      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def assert_add_sub_email_mail_sent(new_email) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】サブメールアドレス追加を完了させてください（24 時間以内有効）"
      assert email.to == [{"", new_email}]
      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def assert_operations_notification_mail_sent(%{message: message, detail: detail}, to_emails) do
    assert_email_sent(fn email ->
      assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
      assert email.subject == "【Bright】運営からのお知らせ"
      assert email.text_body =~ message
      assert email.text_body =~ String.slice(detail, 0, 100)
      assert email.text_body =~ "notifications/operations?operation="

      assert email.provider_options.personalizations ==
               to_emails |> Enum.map(&%{to: [%{email: &1}]})

      assert email.reply_to == {"Brightカスタマーサクセス", "customer-success@bright-fun.org"}
    end)
  end

  def convert_map_string_key_to_atom(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  @doc """
  Returns support dir
  """
  def test_support_dir, do: @test_support_dir

  def setup_subscription_plan(_context) do
    subscription_plans = Bright.Seeds.SubscriptionPlan.insert()

    %{subscription_plans: subscription_plans}
  end

  def find_subscription_plan(plans, name \\ "みんなでワイワイ") do
    plans
    |> Enum.find(fn plan -> plan.name_jp === name end)
  end

  def create_user_with_skill do
    create_skill_for_user(insert(:user))
  end

  def create_skill_for_user(user) do
    skill_panel = insert(:skill_panel)
    user_skill_panel = insert(:user_skill_panel, user: user, skill_panel: skill_panel)
    skill_class_1 = insert(:skill_class, skill_panel: skill_panel, class: 1)
    skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)
    skill_class_3 = insert(:skill_class, skill_panel: skill_panel, class: 3)
    skill_class_score_1 = insert(:skill_class_score, user: user, skill_class: skill_class_1)
    skill_class_score_2 = insert(:skill_class_score, user: user, skill_class: skill_class_2)
    skill_class_score_3 = insert(:skill_class_score, user: user, skill_class: skill_class_3)

    %{
      user: user,
      skill_panel: skill_panel,
      user_skill_panel: user_skill_panel,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2,
      skill_class_3: skill_class_3,
      skill_class_score_1: skill_class_score_1,
      skill_class_score_2: skill_class_score_2,
      skill_class_score_3: skill_class_score_3
    }
  end

  def create_team_with_team_member_users(users) do
    team = insert(:team)

    team_members =
      Enum.map(users, fn user ->
        insert(:team_member_users, team: team, user: user)
      end)

    %{
      team: team,
      team_members: team_members
    }
  end
end
