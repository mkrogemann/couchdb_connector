defmodule Couchdb.Connector.TestConfig do

  def database_properties do
    %{
      protocol: Application.get_env(:couchdb_connector, :protocol),
      hostname: Application.get_env(:couchdb_connector, :hostname),
      database: Application.get_env(:couchdb_connector, :database),
      port: Application.get_env(:couchdb_connector, :port)
    }
  end

  def database_url do
    "#{database_server_url}/#{database_properties[:database]}"
  end

  def database_server_url do
    "#{database_properties[:protocol]}://#{database_properties[:hostname]}:#{database_properties[:port]}"
  end
end
