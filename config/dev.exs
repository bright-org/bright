import Config

# Configure your database
config :bright, Bright.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "bright_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :bright, BrightWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "NscRG+nu4wU6WCH+1dowaRxOfXxlk0W2K36n58kV8bo5e3d/wrsrs/1vqQ+Gj9Rg",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]},
    storybook_tailwind: {Tailwind, :install_and_run, [:storybook, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :bright, BrightWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/bright_web/(controllers|live|components)/.*(ex|heex)$",
      ~r"storybook/.*(exs)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :bright, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Google Cloud Storage (fake server)
config :goth, disabled: true
config :google_api_storage, base_url: System.get_env("GCS_BASE_URL", "http://localhost:4443")

config :bright, :google_api_storage,
  bucket_name: System.get_env("BUCKET_NAME", "bright_storage_local"),
  public_base_url: System.get_env("GCS_PUBLIC_BASE_URL", "http://localhost:4443")

# TODO 「報酬アップを相談」のレビュー時はconfig :logger, level: :warningを削除すること
config :logger, level: :warning

config :boruta, Boruta.Oauth, issuer: "http://localhost:4000"
