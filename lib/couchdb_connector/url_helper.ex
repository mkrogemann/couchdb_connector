defmodule Couchdb.Connector.UrlHelper do
  @moduledoc """
  Provides URL helper functions that compose URLs based on given database
  properties and additional parameters, such as document IDs.

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
  """

  def database_server_url db_props do
    "#{db_props[:protocol]}://#{db_props[:hostname]}:#{db_props[:port]}"
  end

  def database_url db_props do
    "#{database_server_url(db_props)}/#{db_props[:database]}"
  end

  def document_url db_props, id do
    "#{database_url(db_props)}/#{id}"
  end

  def fetch_uuid_url db_props, count \\ 1 do
    "#{database_server_url(db_props)}/_uuids?count=#{count}"
  end

  def design_url db_props, design do
    "#{database_url(db_props)}/_design/#{design}"
  end

  def view_url db_props, design, view do
    "#{design_url(db_props, design)}/_view/#{view}"
  end

  def query_path view_base_url, key, stale do
    "#{view_base_url}?key=\"#{key}\"&stale=#{Atom.to_string(stale)}"
  end

end
