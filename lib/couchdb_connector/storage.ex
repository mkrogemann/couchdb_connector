defmodule Couchdb.Connector.Storage do
  @moduledoc """
  The Storage module provides functions to create and destroy databases.

  ## Examples

      iex>db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}
      iex>Couchdb.Connector.Storage.storage_up(db_props)
      {:ok, "{\\"ok\\":true}\\n"}
      iex>Couchdb.Connector.Storage.storage_down(db_props)
      {:ok, "{\\"ok\\":true}\\n"}

  """

  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Create a database with parameters as given in the db_props map.
  """
  def storage_up db_props do
    db_props
    |> UrlHelper.database_url
    |> HTTPoison.put!("{}", [Headers.json_header])
    |> Handler.handle_put
  end

  @doc """
  Delete the database with the properties as given in the db_props map.
  """
  def storage_down db_props do
    db_props
    |> UrlHelper.database_url
    |> HTTPoison.delete!
    |> Handler.handle_delete
  end
end
