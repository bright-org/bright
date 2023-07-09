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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BrightWeb do
    pipe_through [:browser, :no_header]

    get "/", PageController, :home
  end

  scope "/admin", BrightWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

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

    live "/user_onboardings", UserOnboardingsLive.Index, :index
    live "/user_onboardings/new", UserOnboardingsLive.Index, :new
    live "/user_onboardings/:id/edit", UserOnboardingsLive.Index, :edit
    live "/user_onboardings/:id", UserOnboardingsLive.Show, :show
    live "/user_onboardings/:id/show/edit", UserOnboardingsLive.Show, :edit

    live "/onboarding_wants", OnboardingWantLive.Index, :index
    live "/onboarding_wants/new", OnboardingWantLive.Index, :new
    live "/onboarding_wants/:id/edit", OnboardingWantLive.Index, :edit

    live "/onboarding_wants/:id", OnboardingWantLive.Show, :show
    live "/onboarding_wants/:id/show/edit", OnboardingWantLive.Show, :edit

    live "/user_onboardings", UserOnboardingsLive.Index, :index
    live "/user_onboardings/new", UserOnboardingsLive.Index, :new
    live "/user_onboardings/:id/edit", UserOnboardingsLive.Index, :edit
    live "/user_onboardings/:id", UserOnboardingsLive.Show, :show
    live "/user_onboardings/:id/show/edit", UserOnboardingsLive.Show, :edit

    live "/onboarding_wants", OnboardingWantLive.Index, :index
    live "/onboarding_wants/new", OnboardingWantLive.Index, :new
    live "/onboarding_wants/:id/edit", OnboardingWantLive.Index, :edit
    live "/onboarding_wants/:id", OnboardingWantLive.Show, :show
    live "/onboarding_wants/:id/show/edit", OnboardingWantLive.Show, :edit

    live "/careerfields", CareerfieldsLive.Index, :index
    live "/careerfields/new", CareerfieldsLive.Index, :new
    live "/careerfields/:id/edit", CareerfieldsLive.Index, :edit
    live "/careerfields/:id", CareerfieldsLive.Show, :show
    live "/careerfields/:id/show/edit", CareerfieldsLive.Show, :edit

    live "/jobs", JobLive.Index, :index
    live "/jobs/new", JobLive.Index, :new
    live "/jobs/:id/edit", JobLive.Index, :edit
    live "/jobs/:id", JobLive.Show, :show
    live "/jobs/:id/show/edit", JobLive.Show, :edit

    live "/onboarding_want_jobs", OnboardingWantJobLive.Index, :index
    live "/onboarding_want_jobs/new", OnboardingWantJobLive.Index, :new
    live "/onboarding_want_jobs/:id/edit", OnboardingWantJobLive.Index, :edit
    live "/onboarding_want_jobs/:id", OnboardingWantJobLive.Show, :show
    live "/onboarding_want_jobs/:id/show/edit", OnboardingWantJobLive.Show, :edit

    live "/job_skill_panels", JobSkillPanelsLive.Index, :index
    live "/job_skill_panels/new", JobSkillPanelsLive.Index, :new
    live "/job_skill_panels/:id/edit", JobSkillPanelsLive.Index, :edit
    live "/job_skill_panels/:id", JobSkillPanelsLive.Show, :show
    live "/job_skill_panels/:id/show/edit", JobSkillPanelsLive.Show, :edit

    live "/user_skill_panels", UserSkillPanelsLive.Index, :index
    live "/user_skill_panels/new", UserSkillPanelsLive.Index, :new
    live "/user_skill_panels/:id/edit", UserSkillPanelsLive.Index, :edit
    live "/user_skill_panels/:id", UserSkillPanelsLive.Show, :show
    live "/user_skill_panels/:id/show/edit", UserSkillPanelsLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", BrightWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
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

  ## Authentication routes

  scope "/", BrightWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :no_header]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BrightWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/finish_registration", UserFinishRegistrationLive, :show
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BrightWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BrightWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/mypage", MypageLive.Index, :index
      live "/onboardings", OnboardingLive.Index, :index
      live "/onboardings/:onboarding", OnboardingLive.Index, :index
      live "/panels/:skill_panel_id/graph", SkillPanelLive.Graph, :show
      live "/panels/:skill_panel_id/skills", SkillPanelLive.Skills, :show
      live "/teams", MyTeamLive, :index
      live "/teams/new", TeamCreateLive, :new
    end
  end

  scope "/", BrightWeb do
    pipe_through [:browser, :no_header]

    get "/users/confirm/:token", UserConfirmationController, :confirm
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BrightWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
