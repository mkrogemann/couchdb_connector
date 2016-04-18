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
    A connector for CouchDB, the Erlang-based, JSON document database.

    The connector does not implement the protocols defined in Ecto.
    Reasons: CouchDB does not support transactions as known in the world of
    ACID compliant, relational databases.
    The concept of migrations also does not apply to CouchDB.
    And since CouchDB does not implement an SQL dialect, the decision was taken
    to not follow the standards established by Ecto.

    The connector offers 'create', 'update' and 'read' operations through its
    Writer and Reader modules.
    Basic support for view operations is provided by the View module.

    There are also management functions for users and admins.

    Basic access authentication (basic auth) is supported.
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
