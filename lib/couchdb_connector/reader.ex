defmodule Couchdb.Connector.Reader do
  @moduledoc """
  The Reader module provides functions to retrieve documents or uuids from
  CouchDB.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.fetch_uuid(db_props)
      :ok, "{\\"uuids\\":[\\"1a013a4ce3...\\"]}\\n"}

      Couchdb.Connector.get(db_props, "_not_there_")
      :error, "{\\"error\\":\\"not_found\\",\\"reason\\":\\"missing\\"}\\n"}

  """

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Retrieve the document given by database properties and id.
  """
  def get db_props, id do
    db_props
    |> UrlHelper.document_url(id)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Fetch a single uuid from CouchDB for use in a a subsequent create operation.
  """
  def fetch_uuid db_props do
    db_props
    |> UrlHelper.fetch_uuid_url
    |> HTTPoison.get!
    |> Handler.handle_get
  end
end
