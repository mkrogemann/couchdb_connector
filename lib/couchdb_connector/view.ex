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
  Returns everything found for the given view in the given design document,
  using no authentication.
  """
  @spec fetch_all(Types.db_properties, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def fetch_all(db_props, design, view) do
    db_props
    |> UrlHelper.view_url(design, view)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Returns everything found for the given view in the given design document,
  using basic authentication.
  """
  @spec fetch_all(Types.db_properties, Types.basic_auth, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def fetch_all(db_props, auth, design, view) do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.fetch_all/4 is deprecated, please use fetch_all/3 instead\n"
    fetch_all(Map.merge(db_props, auth), design, view)
  end

  @doc """
  Create a view with the given JavaScript code in the given design document.
  Admin credentials are required for this operation.
  """
  @spec create_view(Types.db_properties, Types.basic_auth, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def create_view(db_props, admin_auth, design, code) do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.create_view/4 is deprecated, please use create_view/3 instead\n"
    create_view(Map.merge(db_props, admin_auth), design, code)
  end

  @doc """
  Create a view with the given JavaScript code in the given design document.
  """
  @spec create_view(Types.db_properties, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def create_view(db_props, design, code) do
    db_props
    |> UrlHelper.design_url(design)
    |> HTTPoison.put!(code)
    |> Handler.handle_put
  end

  @doc """
  Find and return one document with given key in given view, using basic
  authentication.
  Will return a JSON document with an empty list of documents if no document
  with given key exists.
  Staleness is set to 'update_after' which will perform worse than 'ok' but
  deliver more up-to-date results.
  """
  @spec document_by_key(Types.db_properties, Types.basic_auth, Types.view_key, :update_after)
    :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, auth, view_key, :update_after) do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.document_by_key/4 is deprecated, please use document_by_key/3 instead\n"
    document_by_key(Map.merge(db_props, auth), view_key, :update_after)
  end

  @doc """
  Find and return one document with given key in given view, using basic
  authentication.
  Will return a JSON document with an empty list of documents if no document
  with given key exists.
  Staleness is set to 'ok' which will perform better than 'update_after' but
  potentially deliver stale results.
  """
  @spec document_by_key(Types.db_properties, Types.basic_auth, Types.view_key, :ok)
    :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, auth, view_key, :ok) do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.document_by_key/4 is deprecated, please use document_by_key/3 instead\n"
    document_by_key(Map.merge(db_props, auth), view_key, :ok)
  end

  # TODO: evaluate if this method actually needs to be public, otherwise delete
  def authenticated_document_by_key(db_props, auth, view_key, stale) do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.authenticated_document_by_key/4 is deprecated, please use unauthenticated_document_by_key/3 instead\n"
    unauthenticated_document_by_key(Map.merge(db_props, auth), view_key, stale)
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
    do: unauthenticated_document_by_key(db_props, view_key, :update_after)

  @doc """
  Find and return one document with given key in given view. Will return a
  JSON document with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'ok'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key, :ok)
    :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, view_key, :ok),
    do: unauthenticated_document_by_key(db_props, view_key, :ok)

  @doc """
  Find and return one document with given key in given view, using basic
  authentication.
  Will return a JSON document with an empty list of documents if no document
  with given key exists.
  Staleness is set to 'update_after' which will perform worse than 'ok' but
  deliver more up-to-date results.
  """
  @spec document_by_key(Types.db_properties, Types.basic_auth, Types.view_key)
    :: {:ok, String.t} | {:error, String.t}
  def document_by_key(db_props, auth, view_key) when is_map(auth) do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.document_by_key/3 is deprecated, please use document_by_key/2 instead\n"
    document_by_key(Map.merge(db_props, auth), view_key)
  end

  # TODO as with the new api, this method can be used authenticated and unauthenticated
  def unauthenticated_document_by_key(db_props, view_key, stale) do
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

  @doc """
  Find and return one document with given key in given view. Will return a
  JSON document with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'update_after'.
  """
  def document_by_key db_props, design, view, key, stale \\ :update_after do
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.document_by_key/5 is deprecated, please use document_by_key/3 instead\n"
    document_by_key(db_props, %{design: design, view: view, key: key}, stale)
  end
end
