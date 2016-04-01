defmodule Couchdb.Connector.UrlHelper do
  @moduledoc """
  Provides URL helper functions that compose URLs based on given database
  properties and additional parameters, such as document IDs, usernames, etc.

  Most of the time, these functions will be used internally. There should
  rarely be a need to access these from within your application.

  ## Examples

      iex>db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}
      iex>Couchdb.Connector.UrlHelper.database_url(db_props)
      "http://localhost:5984/couchdb_connector_test"
      iex>Couchdb.Connector.UrlHelper.document_url(db_props, "5c09dbf93fd6226c414fad5b84004d7c")
      "http://localhost:5984/couchdb_connector_test/5c09dbf93fd6226c414fad5b84004d7c"
      iex>Couchdb.Connector.UrlHelper.view_url(db_props, "test_design", "test_view")
      "http://localhost:5984/couchdb_connector_test/_design/test_design/_view/test_view"
      iex>Couchdb.Connector.UrlHelper.fetch_uuid_url(db_props)
      "http://localhost:5984/_uuids?count=1"
      iex>Couchdb.Connector.UrlHelper.fetch_uuid_url(db_props, _count = 10)
      "http://localhost:5984/_uuids?count=10"
      iex>Couchdb.Connector.UrlHelper.user_url(db_props, "jan")
      "http://localhost:5984/_users/org.couchdb.user:jan"
  """

  use Couchdb.Connector.Types

  @doc """
  Produces the URL to the server given in db_props.
  """
  @spec database_server_url(db_properties) :: String.t
  def database_server_url db_props do
    "#{db_props[:protocol]}://#{db_props[:hostname]}:#{db_props[:port]}"
  end

  @doc """
  Produces the URL to the server given in db_props including
  basic auth parameters
  """
  @spec database_server_url(db_properties, String.t, String.t) :: String.t
  def database_server_url db_props, username, password do
    "#{db_props[:protocol]}://#{username}:#{password}@#{db_props[:hostname]}:#{db_props[:port]}"
  end

  @doc """
  Produces the URL to a specific database hosted on the given server.
  """
  @spec database_url(db_properties) :: String.t
  def database_url db_props do
    "#{database_server_url(db_props)}/#{db_props[:database]}"
  end

  @doc """
  Produces the URL to a specific document contained in given database.
  """
  @spec document_url(db_properties, String.t) :: String.t
  def document_url db_props, id do
    "#{database_url(db_props)}/#{id}"
  end

  @doc """
  Produces an URL that can be used to retrieve the given number of UUIDs from
  CouchDB.
  """
  @spec fetch_uuid_url(db_properties, non_neg_integer) :: String.t
  def fetch_uuid_url db_props, count \\ 1 do
    "#{database_server_url(db_props)}/_uuids?count=#{count}"
  end

  @doc """
  Produces the URL to a specific design document.
  """
  @spec design_url(db_properties, String.t) :: String.t
  def design_url db_props, design do
    "#{database_url(db_props)}/_design/#{design}"
  end

  @doc """
  Produces the URL to a specific view from a given design document.
  """
  @spec view_url(db_properties, String.t, String.t) :: String.t
  def view_url db_props, design, view do
    "#{design_url(db_props, design)}/_view/#{view}"
  end

  @doc """
  Produces the URL to query a view for a specific key, using the provided
  staleness setting (either :ok or :update_after).
  """
  @spec query_path(String.t, String.t, atom) :: String.t
  def query_path view_base_url, key, stale do
    "#{view_base_url}?key=\"#{key}\"&stale=#{Atom.to_string(stale)}"
  end

  @doc """
  Produces the URL to a specific user.
  """
  @spec user_url(db_properties, String.t) :: String.t
  def user_url db_props, username do
    "#{database_server_url(db_props)}/_users/org.couchdb.user:#{username}"
  end

  @doc """
  Produces the URL to a specific admin.
  """
  @spec admin_url(db_properties, String.t) :: String.t
  def admin_url db_props, username do
    "#{database_server_url(db_props)}/_config/admins/#{username}"
  end

  @doc """
  Produces the URL to a specific admin, including basic auth params
  """
  @spec admin_url(db_properties, String.t, String.t) :: String.t
  def admin_url db_props, username,password do
    "#{database_server_url(db_props, username, password)}/_config/admins/#{username}"
  end
end
