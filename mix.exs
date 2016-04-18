defmodule Couchdb.Connector.Mixfile do
  use Mix.Project

  def project do
    [
      app: :couchdb_connector,
      version: "0.4.0",
      elixir: "~> 1.1",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description,
      package: package,
      deps: deps,
      dialyzer: [plt_add_apps: [:poison, :httpoison]],
      test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:logger, :httpoison, :poison],
     mod: {Couchdb.Connector.Supervisor, [name: :couchdb_connector_sup]}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8.0"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:excoveralls, "0.4.6", only: [:dev, :test]},
      {:credo, "~> 0.2", only: [:dev, :test]},
      {:earmark, "0.2.1", only: :dev},
      {:ex_doc, "0.11.4", only: :dev},
      {:dialyxir, "~> 0.3", only: [:dev]}
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
      maintainers: ["Markus Krogemann", "Marcel Wolf"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/locolupo/couchdb_connector"}
    ]
  end
end
