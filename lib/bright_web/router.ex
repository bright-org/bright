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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BrightWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/bright_users", BrightUserLive.Index, :index
    live "/bright_users/new", BrightUserLive.Index, :new
    live "/bright_users/:id/edit", BrightUserLive.Index, :edit

    live "/bright_users/:id", BrightUserLive.Show, :show
    live "/bright_users/:id/show/edit", BrightUserLive.Show, :edit

    live "/teams", TeamLive.Index, :index
    live "/teams/new", TeamLive.Index, :new
    live "/teams/:id/edit", TeamLive.Index, :edit

    live "/teams/:id", TeamLive.Show, :show
    live "/teams/:id/show/edit", TeamLive.Show, :edit

    live "/user_joined_teams", UserJoinedTeamLive.Index, :index
    live "/user_joined_teams/new", UserJoinedTeamLive.Index, :new
    live "/user_joined_teams/:id/edit", UserJoinedTeamLive.Index, :edit

    live "/user_joined_teams/:id", UserJoinedTeamLive.Show, :show
    live "/user_joined_teams/:id/show/edit", UserJoinedTeamLive.Show, :edit


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

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BrightWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
