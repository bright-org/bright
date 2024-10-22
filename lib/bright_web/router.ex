defmodule BrightWeb.Router do
  use BrightWeb, :router

  import BrightWeb.UserAuth
  import BrightWeb.InitAssigns, only: [fetch_current_request_path: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BrightWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_current_request_path
  end

  pipeline :admin do
    plug :admin_basic_auth
    plug :put_root_layout, html: {BrightWeb.Layouts, :admin}
  end

  pipeline :auth do
    plug :put_root_layout, html: {BrightWeb.Layouts, :auth}
  end

  pipeline :onboarding do
    plug :put_root_layout, html: {BrightWeb.Layouts, :onboarding}
  end

  pipeline :share do
    plug :put_root_layout, html: {BrightWeb.Layouts, :share}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # デバッグ用画面（prod環境以外）
  scope "/", BrightWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :home
  end

  # 管理画面
  scope "/admin", BrightWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    live_session :fetch_current_user,
      on_mount: [
        {BrightWeb.UserAuth, :mount_current_user},
        {BrightWeb.InitAssigns, :without_header}
      ] do
      live "/skill_panels", SkillPanelLive.Index, :index
      live "/skill_panels/new", SkillPanelLive.Index, :new
      live "/skill_panels/:id/edit", SkillPanelLive.Index, :edit
      live "/skill_panels/:id", SkillPanelLive.Show, :show
      live "/skill_panels/:id/show/edit", SkillPanelLive.Show, :edit

      live "/skill_units", SkillUnitLive.Index, :index
      live "/skill_units/new", SkillUnitLive.Index, :new
      live "/skill_units/:id/edit", SkillUnitLive.Index, :edit
      live "/skill_units/:id", SkillUnitLive.Show, :show
      live "/skill_units/:id/show/edit", SkillUnitLive.Show, :edit
      live "/skill_categories/:id/show/edit", SkillCategoryLive.Show, :edit
      live "/skills/:id/show/edit", SkillLive.Show, :edit

      live "/user_onboardings", UserOnboardingLive.Index, :index
      live "/user_onboardings/new", UserOnboardingLive.Index, :new
      live "/user_onboardings/:id/edit", UserOnboardingLive.Index, :edit
      live "/user_onboardings/:id", UserOnboardingLive.Show, :show
      live "/user_onboardings/:id/show/edit", UserOnboardingLive.Show, :edit

      live "/career_wants", CareerWantLive.Index, :index
      live "/career_wants/new", CareerWantLive.Index, :new
      live "/career_wants/:id/edit", CareerWantLive.Index, :edit
      live "/career_wants/:id", CareerWantLive.Show, :show
      live "/career_wants/:id/show/edit", CareerWantLive.Show, :edit

      live "/career_fields", CareerFieldLive.Index, :index
      live "/career_fields/new", CareerFieldLive.Index, :new
      live "/career_fields/:id/edit", CareerFieldLive.Index, :edit
      live "/career_fields/:id", CareerFieldLive.Show, :show
      live "/career_fields/:id/show/edit", CareerFieldLive.Show, :edit

      live "/jobs", JobLive.Index, :index
      live "/jobs/new", JobLive.Index, :new
      live "/jobs/:id/edit", JobLive.Index, :edit
      live "/jobs/:id", JobLive.Show, :show
      live "/jobs/:id/show/edit", JobLive.Show, :edit

      live "/career_want_jobs", CareerWantJobLive.Index, :index
      live "/career_want_jobs/new", CareerWantJobLive.Index, :new
      live "/career_want_jobs/:id/edit", CareerWantJobLive.Index, :edit
      live "/career_want_jobs/:id", CareerWantJobLive.Show, :show
      live "/career_want_jobs/:id/show/edit", CareerWantJobLive.Show, :edit

      live "/job_skill_panels", JobSkillPanelLive.Index, :index
      live "/job_skill_panels/new", JobSkillPanelLive.Index, :new
      live "/job_skill_panels/:id/edit", JobSkillPanelLive.Index, :edit
      live "/job_skill_panels/:id", JobSkillPanelLive.Show, :show
      live "/job_skill_panels/:id/show/edit", JobSkillPanelLive.Show, :edit

      live "/subscription_plans", SubscriptionPlanLive.Index, :index
      live "/subscription_plans/new", SubscriptionPlanLive.Index, :new
      live "/subscription_plans/:id/edit", SubscriptionPlanLive.Index, :edit
      live "/subscription_plans/:id", SubscriptionPlanLive.Show, :show
      live "/subscription_plans/:id/show/edit", SubscriptionPlanLive.Show, :edit

      live "/subscription_plan_services", SubscriptionPlanServiceLive.Index, :index
      live "/subscription_plan_services/new", SubscriptionPlanServiceLive.Index, :new
      live "/subscription_plan_services/:id/edit", SubscriptionPlanServiceLive.Index, :edit
      live "/subscription_plan_services/:id", SubscriptionPlanServiceLive.Show, :show
      live "/subscription_plan_services/:id/show/edit", SubscriptionPlanServiceLive.Show, :edit

      live "/subscription_user_plans", SubscriptionUserPlanLive.Index, :index
      live "/subscription_user_plans/new", SubscriptionUserPlanLive.Index, :new
      live "/subscription_user_plans/:id/edit", SubscriptionUserPlanLive.Index, :edit
      live "/subscription_user_plans/:id", SubscriptionUserPlanLive.Show, :show
      live "/subscription_user_plans/:id/show/edit", SubscriptionUserPlanLive.Show, :edit

      live "/recruits/interviews", InterviewLive.Index, :index
      live "/recruits/interviews/new", InterviewLive.Index, :new
      live "/recruits/interviews/:id/edit", InterviewLive.Index, :edit
      live "/recruits/interviews/:id", InterviewLive.Show, :show
      live "/recruits/interviews/:id/show/edit", InterviewLive.Show, :edit

      live "/team_supporter_teams", TeamSupporterTeamLive.Index, :index
      live "/team_supporter_teams/new", TeamSupporterTeamLive.Index, :new
      live "/team_supporter_teams/:id/edit", TeamSupporterTeamLive.Index, :edit
      live "/team_supporter_teams/:id", TeamSupporterTeamLive.Show, :show
      live "/team_supporter_teams/:id/show/edit", TeamSupporterTeamLive.Show, :edit

      # ドラフト編集ツール
      live "/draft_skill_classes/:id", DraftSkillClassLive.Show, :show
      live "/draft_skill_classes/:id/edit", DraftSkillClassLive.Show, :edit_skill_class
      live "/draft_skill_classes/:id/skill_units/new", DraftSkillClassLive.Show, :new_skill_unit
      live "/draft_skill_classes/:id/skill_units/add", DraftSkillClassLive.Show, :add_skill_unit

      live "/draft_skill_classes/:id/skill_units/:skill_unit_id/edit",
           DraftSkillClassLive.Show,
           :edit_skill_unit

      live "/draft_skill_classes/:id/skill_units/:skill_unit_id/replace",
           DraftSkillClassLive.Show,
           :replace_skill_unit

      live "/draft_skill_classes/:id/skill_categories/new",
           DraftSkillClassLive.Show,
           :new_skill_category

      live "/draft_skill_classes/:id/skill_categories/:skill_category_id/edit",
           DraftSkillClassLive.Show,
           :edit_skill_category

      live "/draft_skill_classes/:id/skill_categories/:skill_category_id/replace",
           DraftSkillClassLive.Show,
           :replace_skill_category

      live "/draft_skill_classes/:id/skills/new", DraftSkillClassLive.Show, :new_skill
      live "/draft_skill_classes/:id/skills/:skill_id/edit", DraftSkillClassLive.Show, :edit_skill

      live "/draft_skill_classes/:id/skills/:skill_id/replace",
           DraftSkillClassLive.Show,
           :replace_skill

      # 本番編集ツール
      live "/skill_classes/:id", SkillClassLive.Show, :show
      live "/skill_classes/:id/skills/:skill_id/edit", SkillClassLive.Show, :edit_skill

      live "/skill_classes/:id/skills/:skill_id/show_reference",
           SkillClassLive.Show,
           :show_reference

      live "/skill_classes/:id/skills/:skill_id/show_exam", SkillClassLive.Show, :show_exam

      if System.get_env("SERVER") == "dev" do
        live "/user_tokens", UserTokenLive.Index, :index
      end

      live "/user_tokens", UserTokenLive.Index, :index
    end
  end

  # ローカル開発用
  if Application.compile_env(:bright, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router
    import PhoenixStorybook.Router

    scope "/" do
      storybook_assets()
    end

    scope "/", BrightWeb do
      pipe_through :browser

      live_storybook("/storybook", backend_module: BrightWeb.Storybook)
    end

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BrightWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/dev" do
      pipe_through [:browser, :admin]

      live "/user_tokens", BrightWeb.Admin.UserTokenLive.Index, :index
    end
  end

  # 認証前
  ## ユーザー登録・ログイン
  scope "/", BrightWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :auth]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {BrightWeb.UserAuth, :redirect_if_user_is_authenticated},
        {BrightWeb.InitAssigns, :without_header}
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/finish_registration", UserFinishRegistrationLive, :show
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/users/send_reset_password_url", UserSendResetPasswordUrlLive, :show
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
      live "/users/two_factor_auth/:token", UserTwoFactorAuthLive, :show
      live "/users/register_social_account/:token", UserRegisterSocialAccountLive, :show
    end

    get "/users/confirm/:token", UserConfirmationController, :confirm
    post "/users/log_in", UserSessionController, :create
    post "/users/two_factor_auth", UserTwoFactorAuthController, :create
  end

  # 認証後
  scope "/", BrightWeb do
    pipe_through [:browser, :require_authenticated_user, :require_onboarding]

    live_session :require_authenticated_user,
      on_mount: [
        {BrightWeb.UserAuth, :ensure_authenticated},
        {BrightWeb.UserAuth, :ensure_onboarding},
        BrightWeb.InitAssigns
      ] do
      live "/mypage", MypageLive.Index, :index
      live "/mypage/:user_name", MypageLive.Index, :index
      live "/mypage/anon/:user_name_encrypted", MypageLive.Index, :index

      live "/searches", MypageLive.Index, :search
      live "/free_trial", MypageLive.Index, :free_trial
      live "/skill_select", OnboardingLive.Index, :index
      live "/skill_select/:skill_panel_id", OnboardingLive.SkillInputs, :show

      live "/skills", OnboardingLive.SkillInputs, :show
      live "/skills/:skill_panel_id", OnboardingLive.SkillInputs, :show
      live "/skills/:skill_panel_id/:user_name", OnboardingLive.SkillInputs, :show

      live "/skills/:skill_panel_id/anon/:user_name_encrypted",
           OnboardingLive.SkillInputs,
           :show

      live "/skills/:skill_panel_id/skills/:skill_id/evidences",
           OnboardingLive.SkillInputs,
           :show_evidences

      live "/skills/:skill_panel_id/skills/:skill_id/reference",
           OnboardingLive.SkillInputs,
           :show_reference

      live "/skills/:skill_panel_id/skills/:skill_id/exam",
           OnboardingLive.SkillInputs,
           :show_exam

      live "/skills/:skill_panel_id/edit", OnboardingLive.SkillInputs, :edit

      live "/graphs", GraphLive.Graphs, :show
      live "/graphs/:skill_panel_id", GraphLive.Graphs, :show
      live "/graphs/:skill_panel_id/:user_name", GraphLive.Graphs, :show
      live "/graphs/:skill_panel_id/anon/:user_name_encrypted", GraphLive.Graphs, :show

      live "/panels", SkillPanelLive.Skills, :show
      live "/panels/:skill_panel_id", SkillPanelLive.Skills, :show
      live "/panels/:skill_panel_id/edit", SkillPanelLive.Skills, :edit
      live "/panels/:skill_panel_id/:user_name", SkillPanelLive.Skills, :show
      live "/panels/:skill_panel_id/anon/:user_name_encrypted", SkillPanelLive.Skills, :show

      live "/panels/:skill_panel_id/skills/:skill_id/evidences",
           SkillPanelLive.Skills,
           :show_evidences

      live "/panels/:skill_panel_id/skills/:skill_id/reference",
           SkillPanelLive.Skills,
           :show_reference

      live "/panels/:skill_panel_id/skills/:skill_id/exam",
           SkillPanelLive.Skills,
           :show_exam

      live "/teams", MyTeamLive, :index
      live "/teams/new", MyTeamLive, :new
      live "/teams/:team_id", MyTeamLive, :index
      live "/teams/:team_id/edit", MyTeamLive, :edit
      live "/teams/:team_id/skill_panels/:skill_panel_id", MyTeamLive, :index

      live "/team_supports", TeamSupportLive.Index, :index
      live "/team_supports/:team_supporter_team_id", TeamSupportLive.Index, :edit

      live "/notifications/operations", NotificationLive.Operation, :index
      live "/notifications/communities", NotificationLive.Community, :index
      live "/notifications/evidences", NotificationLive.Evidence, :index
      live "/notifications/evidences/:skill_evidence_id", NotificationLive.Evidence, :show
      live "/notifications/skill_updates", NotificationLive.SkillUpdate, :index

      live "/recruits/interviews", RecruitInterviewLive.Index, :index
      live "/recruits/interviews/:id", RecruitInterviewLive.Index, :show_interview
      live "/recruits/interviews/member/:id", RecruitInterviewLive.Index, :show_member
      live "/recruits/coordinations", RecruitCoordinationLive.Index, :index
      live "/recruits/coordinations/:id", RecruitCoordinationLive.Index, :show_interview
      live "/recruits/coordinations/member/:id", RecruitCoordinationLive.Index, :show_member

      live "/recruits/coordinations/acceptance/:id",
           RecruitCoordinationLive.Index,
           :show_acceptance

      live "/recruits/employments", RecruitEmploymentLive.Index, :index
      live "/recruits/employments/:id", RecruitEmploymentLive.Index, :team_join
      live "/recruits/employments/team_join/:id", RecruitEmploymentLive.Index, :team_invite

      live "/recruits/chats", ChatLive.Index, :recruit
      live "/recruits/chats/:id", ChatLive.Index, :recruit
    end

    ## OAuth
    scope "/auth" do
      delete "/:provider", OAuthController, :delete
    end

    post "/users/password_reset", UserPasswordResetController, :create
    get "/users/confirm_email/:token", UserConfirmEmailController, :confirm
    get "/users/confirm_sub_email/:token", UserConfirmSubEmailController, :confirm
    get "/get_skill_panel/:skill_panel_id", SkillPanelController, :get_skill_panel
    get "/get_skill_panel/:skill_panel_id/:ogp", SkillPanelController, :get_skill_panel
  end

  # オンボーディング
  scope "/onboardings", BrightWeb do
    pipe_through [
      :browser,
      :require_authenticated_user,
      :redirect_if_onboarding_finished,
      :onboarding
    ]

    live_session :require_authenticated_user_onboarding,
      on_mount: [
        {BrightWeb.UserAuth, :ensure_authenticated},
        {BrightWeb.UserAuth, :redirect_if_onboarding_finished},
        {BrightWeb.InitAssigns, :without_header}
      ] do
      live "/", OnboardingLive.Index, :index
      live "/welcome", OnboardingLive.Welcome
      live "/:job_id", OnboardingLive.SkillPanel
    end
  end

  # 認証前後問わない
  scope "/", BrightWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/teams/invitation_confirm/:token", TeamInvitationConfirmController, :invitation_confirm

    ## OAuth
    scope "/auth" do
      get "/:provider", OAuthController, :request
      get "/:provider/callback", OAuthController, :callback
    end
  end

  # 認証前後問わない
  ## シェア用のURL
  scope "/share", BrightWeb.Share do
    pipe_through [:browser, :share]

    live_session :share,
      on_mount: [
        {BrightWeb.UserAuth, :mount_current_user},
        {BrightWeb.InitAssigns, :without_header}
      ] do
      live "/:share_graph_token/graphs", GraphLive.Graphs, :show
    end
  end

  scope "/api", BrightWeb.Api do
    pipe_through [:api, :api_basic_auth]

    scope "/v1" do
      resources "/notification_operations", NotificationOperationController, except: [:new, :edit]

      resources "/notification_communities", NotificationCommunityController,
        except: [:new, :edit]
    end
  end

  # Boruta
  scope "/oauth", BrightWeb.Oauth do
    pipe_through :api

    post "/revoke", RevokeController, :revoke
    post "/token", TokenController, :token
    post "/introspect", IntrospectController, :introspect
  end

  scope "/openid", BrightWeb.Openid do
    pipe_through [:api]

    get "/userinfo", UserinfoController, :userinfo
    post "/userinfo", UserinfoController, :userinfo
    get "/jwks", JwksController, :jwks_index
  end

  scope "/oauth", BrightWeb.Oauth do
    pipe_through [:browser, :fetch_current_user]

    get "/authorize", AuthorizeController, :authorize
  end

  scope "/openid", BrightWeb.Openid do
    pipe_through [:browser, :fetch_current_user]

    get "/authorize", AuthorizeController, :authorize
  end

  scope "/.well-known", BrightWeb do
    pipe_through [:api]

    get "/openid-configuration", Openid.WellKnownController, :configuration
  end

  # See https://hexdocs.pm/plug/Plug.BasicAuth.html#module-runtime-time-usage
  defp admin_basic_auth(conn, _opts) do
    case System.fetch_env("MIX_ENV") do
      # NOTE: ローカル環境以外は MIX_ENV=prod になる（Dockerfileを参照）
      {:ok, "prod"} ->
        username = System.fetch_env!("ADMIN_BASIC_AUTH_USERNAME")
        password = System.fetch_env!("ADMIN_BASIC_AUTH_PASSWORD")
        Plug.BasicAuth.basic_auth(conn, username: username, password: password)

      _ ->
        conn
    end
  end

  defp api_basic_auth(conn, _opts) do
    username = Application.fetch_env!(:bright, :api_basic_auth_username)
    password = Application.fetch_env!(:bright, :api_basic_auth_password)
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
