defmodule Bright.MixProject do
  use Mix.Project

  def project do
    [
      app: :bright,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Bright.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/factories"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.3"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      # NOTE: 0.17 以降だと nimble_options の warning が出て煩わしいので低いバージョンに固定。修正されたら ~> 0.16 にする。
      {:finch, "~> 0.16.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mix_test_observer, "~> 0.1", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.7", only: :test},
      {:faker, "~> 0.17", only: :test},
      {:ecto_ulid_next, "~> 1.0"},
      {:phoenix_storybook, "~> 0.5.0"},
      {:google_api_storage, "~> 0.34"},
      {:goth, "~> 1.3"},
      {:hackney, "~> 1.18"},
      {:scrivener_ecto, "~> 2.0"},
      {:ueberauth_google, "~> 0.10"},
      {:timex, "~> 3.7"},
      {:tzdata, "~> 1.1"},
      {:sentry, "~> 8.0"},
      {:mock, "~> 0.3.8", only: :test},
      {:ex_parameterized, "~> 1.3", only: :test},
      {:ueberauth_github, "~> 0.8"},
      {:earmark, "~> 1.4"},
      {:boruta, "~> 2.3"},
      {:mox, "~> 1.1", only: :test},
      {:eqrcode, "~> 0.1.10"},
      {:tesla, "~> 1.12"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.seed.dummy": ["run priv/repo/seed_dummy_data.exs"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "cmd --cd assets npm install"
      ],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": [
        "assets.setup",
        "tailwind default --minify",
        "esbuild default --minify",
        "tailwind storybook --minify",
        "phx.digest"
      ]
    ]
  end
end
