defmodule BrightWeb.Router do
  use BrightWeb, :router

  import BrightWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BrightWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :admin do
    # credo:disable-for-next-line
    # TODO: Basic認証みたいな軽いアクセス制限を入れる
    # See https://hexdocs.pm/plug/Plug.BasicAuth.html
    plug :put_root_layout, html: {BrightWeb.Layouts, :admin}
  end

  pipeline :no_header do
    plug :put_root_layout, html: {BrightWeb.Layouts, :auth}
  end

  pipeline :onboarding do
    plug :put_root_layout, html: {BrightWeb.Layouts, :onboarding}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # TODO 本番では出ないように
  scope "/", BrightWeb do
    pipe_through [:browser, :no_header]

    get "/", PageController, :home
  end

  # 管理画面
  scope "/admin", BrightWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    live_session :fetch_current_user,
      on_mount: [{BrightWeb.UserAuth, :mount_current_user}] do
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
  end

  # 認証前
  ## ユーザー登録・ログイン
  scope "/", BrightWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :no_header]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BrightWeb.UserAuth, :redirect_if_user_is_authenticated}] do
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

    post "/users/log_in", UserSessionController, :create
    post "/users/two_factor_auth", UserTwoFactorAuthController, :create
  end

  # 認証後
  scope "/", BrightWeb do
    pipe_through [:browser, :require_authenticated_user, :require_onboarding]

    live_session :require_authenticated_user,
      on_mount: [
        {BrightWeb.UserAuth, :ensure_authenticated},
        {BrightWeb.UserAuth, :ensure_onboarding}
      ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/mypage", MypageLive.Index, :index
      live "/skill_up", OnboardingLive.Index, :index
      live "/skill_up/wants/:want_id", OnboardingLive.SkillPanels
      live "/skill_up/wants/:want_id/skill_panels/:id", OnboardingLive.SkillPanel
      live "/skill_up/jobs/:job_id", OnboardingLive.SkillPanels
      live "/skill_up/jobs/:job_id/skill_panels/:id", OnboardingLive.SkillPanel
      live "/mypage/:user_name", MypageLive.Index, :index
      live "/mypage/anon/:user_name_crypted", MypageLive.Index, :index

      live "/graphs", SkillPanelLive.Graph, :show
      live "/graphs/:skill_panel_id", SkillPanelLive.Graph, :show
      live "/graphs/:skill_panel_id/:user_name", SkillPanelLive.Graph, :show
      live "/graphs/:skill_panel_id/anon/:user_name_crypted", SkillPanelLive.Graph, :show

      live "/panels", SkillPanelLive.Skills, :show
      live "/panels/:skill_panel_id", SkillPanelLive.Skills, :show
      live "/panels/:skill_panel_id/:user_name", SkillPanelLive.Skills, :show
      live "/panels/:skill_panel_id/anon/:user_name_crypted", SkillPanelLive.Skills, :show

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
      live "/teams/:team_id", MyTeamLive, :index
      live "/teams/new", TeamCreateLive, :new
      live "/searches", SearchLive.Index
    end
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
        {BrightWeb.UserAuth, :redirect_if_onboarding_finished}
      ] do
      live "/", OnboardingLive.Index, :index
      live "/wants/:want_id", OnboardingLive.SkillPanels
      live "/wants/:want_id/skill_panels/:id", OnboardingLive.SkillPanel
      live "/jobs/:job_id", OnboardingLive.SkillPanels
      live "/jobs/:job_id/skill_panels/:id", OnboardingLive.SkillPanel
    end
  end

  # 認証前後問わない
  scope "/", BrightWeb do
    pipe_through [:browser]

    get "/users/confirm/:token", UserConfirmationController, :confirm
    delete "/users/log_out", UserSessionController, :delete

    ## OAuth
    scope "/auth" do
      get "/:provider", OAuthController, :request
      get "/:provider/callback", OAuthController, :callback
      delete "/:provider", OAuthController, :delete
    end
  end
end
