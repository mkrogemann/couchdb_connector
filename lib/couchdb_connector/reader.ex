defmodule Couchdb.Connector.Reader do
  @moduledoc """
  The Reader module provides functions to retrieve documents or uuids from
  CouchDB.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.Reader.get(db_props, "_not_there_")
      {:error, "{\\"error\\":\\"not_found\\",\\"reason\\":\\"missing\\"}\\n"}

      Couchdb.Connector.Reader.get(db_props, "ca922a07263524e2feb5fe398303ecf8")
      {:ok,
        "{\\"_id\\":\\"ca922a07263524e2feb5fe398303ecf8\\",\\"_rev\\":\\"1-59414...\\",\\"key\\":\\"value\\"}\\n"}

      Couchdb.Connector.Reader.fetch_uuid(db_props)
      {:ok, "{\\"uuids\\":[\\"1a013a4ce3...\\"]}\\n"}

  """

  alias Couchdb.Connector.Types
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Retrieve the document given by database properties and id, using no
  authentication.
  """
  @spec get(Types.db_properties, String.t) :: {:ok, String.t} | {:error, String.t}
  def get(db_props, id) do
    db_props
    |> UrlHelper.document_url(id)
    |> do_get
  end
  
  @doc """
  Retrieve the document attachment given by database properties, id, 
  and attachment_name using no authentication.
  """
  @spec get_attachment(Types.db_properties, String.t, String.t) 
  :: {:ok, String.t} | {:error, String.t}
  def get_attachment(db_props, id, attachment_name) do
    db_props
    |> UrlHelper.attachment_fetch_url(id)
    |> do_attachment_get
  end
  
  @doc """
  Retrieve the document given by database properties and id, using the given
  basic auth credentials for authentication.
  """
  @spec get(Types.db_properties, Types.basic_auth, String.t) :: {:ok, String.t} | {:error, String.t}
  def get(db_props, basic_auth, id) do
    db_props
    |> UrlHelper.document_url(basic_auth, id)
    |> do_get
  end

  @doc """
  Retrieve the attachment given by database properties, id, and attachment
  name using the given basic auth credentials for authentication.
  """
  @spec get_attachment(Types.db_properties, Types.basic_auth, String.t, 
                       String.t) :: {:ok, String.t} | {:error, String.t}
  def get_attachment(db_props, basic_auth, id, att) do
    db_props
    |> UrlHelper.attachment_fetch_url(basic_auth, id, att)
    |> do_attachment_get
  end

  # MFK
  @spec  has_attachment?(Types.db_properties, String.t) 
  :: :ok | {:error, String.t}
  def has_attachment?(db_props, id) do
    # TODO MFK write the code
    {:error, "function not implemented"}
  end

  @doc """
  Fetch a single uuid from CouchDB for use in a a subsequent create operation.
  """
  @spec fetch_uuid(Types.db_properties) :: {:ok, String.t} | {:error, String.t}
  def fetch_uuid(db_props) do
    db_props
    |> UrlHelper.fetch_uuid_url
    |> do_get
  end

  defp do_get(url) do
    url
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  defp do_attachment_get(url) do
    do_get(url)
  end
end
