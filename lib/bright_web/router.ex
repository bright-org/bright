defmodule BrightWeb.Router do
  use BrightWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BrightWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    # credo:disable-for-next-line
    # TODO: Basic認証みたいな軽いアクセス制限を入れる
    # See https://hexdocs.pm/plug/Plug.BasicAuth.html
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BrightWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/admin", BrightWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]

    live "/skill_panels", SkillPanelLive.Index, :index
    live "/skill_panels/new", SkillPanelLive.Index, :new
    live "/skill_panels/:id/edit", SkillPanelLive.Index, :edit
    live "/skill_panels/:id", SkillPanelLive.Show, :show
    live "/skill_panels/:id/show/edit", SkillPanelLive.Show, :edit
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
end
