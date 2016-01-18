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

  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Options
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Returns everything found for the given view in the given design document.
  """
  def fetch_all db_props, design, view do
    db_props
    |> UrlHelper.view_url(design, view)
    |> HTTPoison.get!(Headers.empty, Options.default)
    |> Handler.handle_get
  end

  @doc """
  Create a view with the given JavaScript code in the given design document.
  """
  def create_view db_props, design, code do
    db_props
    |> UrlHelper.design_url(design)
    |> HTTPoison.put!(code, Headers.empty, Options.default)
    |> Handler.handle_put
  end

  @doc """
  Find and return one document with given key in given view. Will return a
  JSON document with an empty list of documents if no document with given
  key exists.
  """
  def document_by_key db_props, design, view, key, stale \\ :update_after do
    db_props
    |> UrlHelper.view_url(design, view)
    |> UrlHelper.query_path(key, stale)
    |> HTTPoison.get!(Headers.empty, Options.default)
    |> Handler.handle_get
  end
end
