defmodule Bright.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(Sentry.LoggerBackend)

    children = [
      # Start the Telemetry supervisor
      BrightWeb.Telemetry,
      # Start the Ecto repository
      Bright.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bright.PubSub},
      # Start Finch
      {Finch, name: Bright.Finch},
      # Start the Endpoint (http/https)
      BrightWeb.Endpoint
      # Start a worker by calling: Bright.Worker.start_link(arg)
      # {Bright.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bright.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BrightWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
