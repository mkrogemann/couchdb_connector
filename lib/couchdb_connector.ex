defmodule Couchdb.Connector do
  @moduledoc """
  Your primary interface for writing to and reading from CouchDB.
  The exchange format here are Maps. If you want to go more low
  level and deal with JSON strings instead, please consider using
  Couchdb.Connector.Reader or Couchdb.Connector.Writer.
  """

  import Couchdb.Connector.AsMap
  import Couchdb.Connector.AsJson
  alias Couchdb.Connector.Types
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.Writer

  @doc """
  Retrieve the document given by database properties and id, returning it
  as a Map, using no authentication.
  """
  @spec get(Types.db_properties, String.t) :: {:ok, map} | {:error, String.t}
  def get(db_props, id) do
    db_props
    |> Reader.get(id)
    |> as_map
  end

  @doc """
  Retrieve the document given by database properties and id, returning it
  as a Map, using the given basic auth credentials for authentication.
  """
  @spec get(Types.db_properties, Types.basic_auth, String.t) :: {:ok, map} | {:error, String.t}
  def get(db_props, basic_auth, id) do
    db_props
    |> Reader.get(basic_auth, id)
    |> as_map
  end

  @doc """
  Fetch a single uuid from CouchDB for use in a a subsequent create operation.
  Clients can retrieve the returned List of UUIDs by getting the value for key
  "uuids". The List contains only one element (UUID).
  """
  @spec fetch_uuid(Types.db_properties) :: {:ok, map} | {:error, String.t}
  def fetch_uuid(db_props) do
    db_props
    |> Reader.fetch_uuid()
    |> as_map
  end

  @doc """
  Create a new document from given map with given id, using no authentication.
  Clients must make sure that the id has not been used for an existing document
  in CouchDB.
  Either provide a UUID or consider using create_generate in case uniqueness cannot
  be guaranteed.
  """
  @spec create(Types.db_properties, map, String.t)
    :: {:ok, map, Types.headers} | {:error, String.t, Types.headers}
  def create(db_props, doc_map, id) do
    case Writer.create(db_props, as_json(doc_map), id) do
      {:ok, json, headers} -> {:ok, %{:payload => as_map(json), :headers => as_map(headers)}}
      {:error, json, headers} -> {:error, as_map(json), headers}
    end
  end

  @doc """
  Create a new document from given map with given id, using the provided basic
  authentication parameters.
  Clients must make sure that the id has not been used for an existing document
  in CouchDB.
  Either provide a UUID or consider using create_generate in case uniqueness cannot
  be guaranteed.
  """
  @spec create(Types.db_properties, Types.basic_auth, map, String.t)
    :: {:ok, map, Types.headers} | {:error, String.t, Types.headers}
  def create(db_props, auth, doc_map, id) do
    {:ok, json} = db_props
    |> Writer.create(as_json(doc_map), id)
    as_map(json)
  end
end
