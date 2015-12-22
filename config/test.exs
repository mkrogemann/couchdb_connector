use Mix.Config

config :couchdb_connector,
  protocol: "http",
  hostname: "127.0.0.1",
  database: "couchdb_connector_test",
  port: 5984
