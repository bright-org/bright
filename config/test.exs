import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bright, Bright.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "bright_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bright, BrightWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "hQGEmfjIVr75paJq39d5+6mDoLCSn0kskdJo7pZymHS7mMniGmCZso+Kl2+n3gXj",
  server: false

# In test we don't send emails.
config :bright, Bright.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Google Cloud Storage (fake server)
config :goth, disabled: true
config :google_api_storage, base_url: System.get_env("GCS_BASE_URL", "http://localhost:4443")

config :bright, :google_api_storage,
  bucket_id: "bright_storage_local_test",
  public_base_url: System.get_env("GCS_PUBLIC_BASE_URL", "http://localhost:4443")

# NOTE: テスト用に Bright.Ueberauth.Strategy.Test を作成して使用
config :ueberauth, Ueberauth,
  providers: [
    google:
      {Bright.Ueberauth.Strategy.Test,
       [aliased_strategy: Ueberauth.Strategy.Google, default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "dummy_client_id",
  client_secret: "dummy_client_secret"
