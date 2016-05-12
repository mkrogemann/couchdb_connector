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
    db_props
    |> UrlHelper.view_url(auth, design, view)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Create a view with the given JavaScript code in the given design document.
  Admin credentials are required for this operation.
  """
  @spec create_view(Types.db_properties, Types.basic_auth, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def create_view(db_props, admin_auth, design, code) do
    db_props
    |> UrlHelper.design_url(admin_auth, design)
    |> HTTPoison.put!(code)
    |> Handler.handle_put
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
  def document_by_key(db_props, auth, view_key, :update_after),
    do: authenticated_document_by_key(db_props, auth, view_key, :update_after)

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
  def document_by_key(db_props, auth, view_key, :ok),
    do: authenticated_document_by_key(db_props, auth, view_key, :ok)

  defp authenticated_document_by_key(db_props, auth, view_key, stale) do
    db_props
    |> UrlHelper.view_url(auth, view_key[:design], view_key[:view])
    |> UrlHelper.query_path(view_key[:key], stale)
    |> do_document_by_key
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
  def document_by_key(db_props, auth, view_key) when is_map(auth),
    do: document_by_key(db_props, auth, view_key, :update_after)

  defp unauthenticated_document_by_key(db_props, view_key, stale) do
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
    IO.write :stderr, "\nwarning: Couchdb.Connector.View.document_by_key/5 is deprecated, please use document_by_key/2 instead\n"
    document_by_key(db_props, %{design: design, view: view, key: key}, stale)
  end
end
