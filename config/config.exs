# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bright,
  ecto_repos: [Bright.Repo]

# Configures the repo
config :bright, Bright.Repo, migration_primary_key: [name: :id, type: :binary_id]

# Configures the endpoint
config :bright, BrightWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: BrightWeb.ErrorHTML, json: BrightWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Bright.PubSub,
  live_view: [signing_salt: "qPlkVHUZ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :bright, Bright.Mailer, adapter: Swoosh.Adapters.Local

config :bright, BrightWeb.Gettext, default_locale: "ja"
# カラーコード応急処置
config :bright,
  career_field_colors: %{
    "infra" => %{
      dark: "#51971a",
      dazzle: "#f2ffe1"
    },
    "engineer" => %{
      dark: "#165bc8",
      dazzle: "#eefbff"
    },
    "designer" => %{
      dark: "#e96500",
      dazzle: "#ffffdc"
    },
    "marketer" => %{
      dark: "#6b50a4",
      dazzle: "#f1e3ff"
    }
  }

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js js/storybook.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ],
  storybook: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/storybook.css
      --output=../priv/static/assets/storybook.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# ueberauth
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: {System, :get_env, ["GOOGLE_CLIENT_ID"]},
  client_secret: {System, :get_env, ["GOOGLE_CLIENT_SECRET"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
