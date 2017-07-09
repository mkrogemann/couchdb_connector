defmodule Couchdb.Connector.Mixfile do
  use Mix.Project

  def project do
    [
      app: :couchdb_connector,
      version: "0.5.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:poison, :httpoison]],
      test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:logger, :httpoison, :poison],
     mod: {Couchdb.Connector.Supervisor, [name: :couchdb_connector_sup]}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8 or ~> 0.9 or ~> 0.10"},
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0"},
      {:excoveralls, "~> 0.7", only: [:dev, :test]},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:earmark, "~> 1.1", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev]}
    ]
  end

  defp description do
    """
    A connector for CouchDB with support for views and authentication.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Markus Krogemann"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/mkrogemann/couchdb_connector"}
    ]
  end
end
