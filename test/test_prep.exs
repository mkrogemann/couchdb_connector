defmodule Couchdb.Connector.TestPrep do

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.Headers

  def ensure_database do
    {:ok, _} = HTTPoison.put "#{TestConfig.database_url}", "{}", [ Headers.json_header ]
  end

  def delete_database do
    {:ok, _} = HTTPoison.delete "#{TestConfig.database_url}"
  end

  def ensure_document doc, id do
    {:ok, _} = HTTPoison.put "#{TestConfig.database_url}/#{id}", doc, [ Headers.json_header ]
  end

  def ensure_view design_name, code do
    {:ok, _} = HTTPoison.put "#{TestConfig.database_url}/_design/#{design_name}", code, [ Headers.json_header ]
  end
end
