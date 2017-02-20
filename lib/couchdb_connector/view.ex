defmodule Couchdb.Connector.View do
  @moduledoc """
  The View module provides functions for basic CouchDB view handling.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      view_code = File.read!("my_view.json")
      Couchdb.Connector.View.create_view db_props, "my_design", view_code

      Couchdb.Connector.View.document_by_key(db_props, "design_name", "view_name", "key")
      {:ok, "{\\"total_rows\\":3,\\"offset\\":1,\\"rows\\":[\\r\\n{\\"id\\":\\"5c09dbf93fd...\\", ...}

  """

  alias Couchdb.Connector.Types
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Returns everything found for the given view in the given design document.
  """
  @spec fetch_all(Types.db_properties, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def fetch_all(db_props, design, view) do
    db_props
    |> UrlHelper.view_url(design, view)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Create a view with the given JavaScript code in the given design document.
  Please note that Admin credentials are required for this operation in case
  your database uses authentication.
  """
  @spec create_view(Types.db_properties, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def create_view(db_props, design, code) do
    db_props
    |> UrlHelper.design_url(design)
    |> HTTPoison.put!(code)
    |> Handler.handle_put
  end

  @doc """
  Find and return one document with given key in given view. Will return a
  JSON document with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'update_after'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key) :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, view_key),
    do: document_by_key(db_props, view_key, :update_after)

  @doc """
  Find and return one document with given key in given view. Will return a
  JSON document with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'update_after'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key, :update_after)
    :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, view_key, :update_after),
    do: do_document_by_key(db_props, view_key, :update_after)

  @doc """
  Find and return one document with given key in given view. Will return a
  JSON document with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'ok'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key, :ok)
    :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, view_key, :ok),
    do: do_document_by_key(db_props, view_key, :ok)

  @doc """
  Find and return one document with given key in given view, using the given
  staleness setting.
  Will return a JSON document with an empty list of documents if no document
  with given key exists.
  """
  @spec do_document_by_key(Types.db_properties, Types.view_key, :ok | :update_after)
    :: {:ok, String.t} | {:error, String.t}
  def do_document_by_key(db_props, view_key, stale) do
    db_props
    |> UrlHelper.view_url(view_key[:design], view_key[:view])
    |> UrlHelper.query_path(view_key[:key], stale)
    |> do_document_by_key
  end

  defp do_document_by_key(url) do
    url
    |> HTTPoison.get!
    |> Handler.handle_get
  end
end
