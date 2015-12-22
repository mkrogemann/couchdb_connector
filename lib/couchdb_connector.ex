defmodule Couchdb.Connector do
  @moduledoc """
  Provides the external facing functions of the Couchdb Connector.

  Applications should prefer to use this interface rather than the
  underlying modules. There should not be any need to access these
  directly.

  ## Examples

  Throughout the following examples, you will need a map holding the database
  properties. Build one as follows:

      iex>db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

  ### Storage Examples

      iex>db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}
      iex>Couchdb.Connector.storage_up(db_props)
      {:ok, "{\\"ok\\":true}\\n"}
      iex>Couchdb.Connector.storage_down(db_props)
      {:ok, "{\\"ok\\":true}\\n"}


  ### Writer Examples

  The Writer module provides functions to create documents in the CouchDB
  database given by the database properties

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.storage_up(db_props)
      {:ok, "{\\"ok\\":true}\\n"}

      Couchdb.Connector.create_fetch_uuid(db_props, "{\\"key\\": \\"value\\"}")
      {:ok, "{\\"ok\\":true,\\"id\\":\\"7dd00...\\",\\"rev\\":\\"1-59414e7...\\"}\\n",
            [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
             {"Location", "http://localhost:5984/couchdb_connector_test/7dd00..."},
             {"ETag", "\\"1-59414e7...\\""}, {"Date", "Mon, 21 Dec 2015 16:13:23 GMT"},
             {"Content-Type", "text/plain; charset=utf-8"},
             {"Content-Length", "95"}, {"Cache-Control", "must-revalidate"}]}


  ### Reader Examples

  The Reader module provides functions to retrieve documents or uuids from
  CouchDB

  ### View Examples

  """

  alias Couchdb.Connector.Storage
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.Writer
  alias Couchdb.Connector.View

  @doc """
  Create a database with parameters as given in the db_props map
  """
  def storage_up db_props do
    Storage.storage_up db_props
  end

  @doc """
  Delete the database that is given in the db_props map
  """
  def storage_down db_props do
    Storage.storage_down db_props
  end

  @doc """
  Create a new document with given json and a CouchDB generated id.</br>
  <strong>WARNING:</strong> This function maps to a HTTP POST request which
  is not a recommended HTTP verb to use with CouchDB. Depending on the
  infrastructure located between client and CouchDB server, a POST request
  may in certain circumstances be replayed by an intermediary which would
  create two objects in database.</br>
  Therefore please consider using the 'create_fetch_uuid/2' function instead
  """
  def create db_props, json do
    Writer.create(db_props, json)
  end

  @doc """
  Create a new document with given json and given id.
  Note: The id given to this function must ...
  TODO: unclear semantics: more tests, more clarity, do not ignore id
  """
  def create db_props, json, id do
    Writer.create(db_props, json, id)
  end

  @doc """
  Create a new document with given json and a CouchDB generated id. This
  function maps to a HTTP PUT request which is a safer method than POST and
  should be preferred in most circumstances. Fetching the uuid from CouchDB
  does incur a performance penalty as compared to doing a single POST request
  """
  def create_fetch_uuid db_props, json do
    Writer.create_fetch_uuid(db_props, json)
  end

  @doc """
  Retrieve document given by database properties and id
  """
  def get db_props, id do
    Reader.get(db_props, id)
  end

  @doc """
  Fetch a single uuid from CouchDB for use in a a subsequent write operation
  """
  def fetch_uuid db_props do
    Reader.fetch_uuid(db_props)
  end

  def start_link(_repo, _options) do
    {:ok, self}
  end
end
