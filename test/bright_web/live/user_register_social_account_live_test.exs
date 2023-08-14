defmodule BrightWeb.UserRegisterSocialAccountLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  import Bright.Factory
  alias Bright.Accounts.UserToken
  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.User

  defp generate_session_token(%{conn: conn}, provider) do
    user_params = %{
      identifier: "1",
      name: "koyo",
      email: "dummy@example.com"
    }

    token =
      user_params
      |> Map.merge(%{provider: provider})
      |> Accounts.generate_social_identifier_token()

    %{conn: conn, session_token: token} |> Map.merge(user_params)
  end

  defp generate_google_session_token(context) do
    generate_session_token(context, :google)
  end

  describe "invalid token" do
    test "invalid token", %{conn: conn} do
      {:error, {:redirect, to}} = conn |> live(~p"/users/register_social_account/aaaaa")

      assert to == %{
               flash: %{"error" => "セッションの期限が切れました。再度やり直してください。"},
               to: ~p"/users/register"
             }
    end
  end

  describe "redirect_if_user_is_authenticated" do
    setup [:generate_google_session_token]

    test "redirects onboardings if already logged in and does not finish onboarding", %{
      conn: conn,
      session_token: session_token
    } do
      result =
        conn
        |> log_in_user(insert(:user))
        |> live(~p"/users/register_social_account/#{session_token}")
        |> follow_redirect(conn, ~p"/onboardings")

      assert {:ok, _conn} = result
    end

    test "redirects mypage if already logged in and finished onboarding", %{
      conn: conn,
      session_token: session_token
    } do
      user = insert(:user)
      insert(:user_onboarding, user: user)

      result =
        conn
        |> log_in_user(user)
        |> live(~p"/users/register_social_account/#{session_token}")
        |> follow_redirect(conn, ~p"/mypage")

      assert {:ok, _conn} = result
    end
  end

  describe "GET /users/register_social_account/:token when token is google" do
    setup [:generate_google_session_token]

    test "renders page", %{conn: conn, session_token: session_token, name: name, email: email} do
      {:ok, lv, html} = conn |> live(~p"/users/register_social_account/#{session_token}")

      assert html =~ "ユーザー新規作成"
      assert html =~ "ユーザーを新規作成する"
      assert html =~ "ログインはこちら"

      assert lv |> has_element?(~s|#handle_name[value="#{name}"]|)
      assert lv |> has_element?(~s|#email[value="#{email}"]|)
    end

    test "renders Google button", %{conn: conn, session_token: session_token} do
      {:ok, _lv, html} = conn |> live(~p"/users/register_social_account/#{session_token}")

      assert html =~ "Google"
    end
  end

  describe "validate" do
    setup [:generate_google_session_token]

    test "renders errors for invalid data", %{conn: conn, session_token: session_token} do
      {:ok, lv, _html} = live(conn, ~p"/users/register_social_account/#{session_token}")

      result =
        lv
        |> element("#registration_by_social_auth_form")
        |> render_change(
          user: %{
            "name" => String.duplicate("a", 256),
            "email" => "with spaces"
          }
        )

      assert result =~ "255文字以内で入力してください"
      assert result =~ "無効なフォーマットです"
    end
  end

  describe "register user when provider is google" do
    setup [:generate_google_session_token]

    test "creates user, user_token and redirects finish registartion page", %{
      conn: conn,
      session_token: session_token
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/register_social_account/#{session_token}")

      user_params = %{
        name: unique_user_name(),
        email: unique_user_email()
      }

      form(lv, "#registration_by_social_auth_form", user: user_params)
      |> render_submit()
      |> follow_redirect(conn, ~p"/users/finish_registration")

      assert_email_sent(fn email ->
        assert email.subject == "Confirmation instructions"
        assert email.to == [{"", user_params[:email]}]
      end)

      user = Repo.get_by(User, name: user_params[:name])

      assert user
      refute user.confirmed_at
      refute user.password_registered
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm")
    end

    test "renders errors for duplicated name", %{
      conn: conn,
      session_token: session_token
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/register_social_account/#{session_token}")

      user = insert(:user, name: "name")

      result =
        lv
        |> form("#registration_by_social_auth_form",
          user: %{"email" => "dummy@example.com", "name" => user.name}
        )
        |> render_submit()

      assert result =~ "すでに使用されています"
    end

    test "renders errors for duplicated email", %{
      conn: conn,
      session_token: session_token
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/register_social_account/#{session_token}")

      user = insert(:user, name: "name")

      result =
        lv
        |> form("#registration_by_social_auth_form",
          user: %{"email" => user.email, "name" => "koyo"}
        )
        |> render_submit()

      assert result =~ "すでに使用されています"
    end
  end

  describe "log in page navigation" do
    setup [:generate_google_session_token]

    test "redirects to login page when the Log in button is clicked", %{
      conn: conn,
      session_token: session_token
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/register_social_account/#{session_token}")

      {:ok, _login_live, login_html} =
        lv
        |> element("a", "ログインはこちら")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "ログイン"
    end
  end
end
