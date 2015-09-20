defmodule IssuesLeaderboard.Mixfile do
  use Mix.Project

  def project do
    [app: :issues_leaderboard,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {IssuesLeaderboard, []},
     applications: [:cowboy, :httpoison, :logger, :phoenix, :phoenix_ecto,
                    :phoenix_html, :postgrex, :tentacat, :tzdata]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:cowboy, "~> 1.0"},
     {:httpoison, "~> 0.7.3"},
     {:phoenix, "~> 1.0.2"},
     {:phoenix_ecto, "~> 1.1"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:postgrex, ">= 0.0.0"},
     {:tentacat, github: "edgurgel/tentacat"},
     {:timex, "~> 0.18.0"}]
  end
end
