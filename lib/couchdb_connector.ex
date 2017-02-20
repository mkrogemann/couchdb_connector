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
  alias Couchdb.Connector.View
  alias Couchdb.Connector.Writer

  @doc """
  Retrieve the document given by database properties and id, returning it
  as a Map.
  """
  @spec get(Types.db_properties, String.t) :: {:ok, map} | {:error, map}
  def get(db_props, id) do
    db_props
    |> Reader.get(id)
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
  Create a new document from given map with given id.
  Clients must make sure that the id has not been used for an existing document
  in CouchDB.
  Either provide a UUID or consider using create_generate in case uniqueness cannot be guaranteed.
  """
  @spec create(Types.db_properties, map, String.t) :: {:ok, map} | {:error, map}
  def create(db_props, doc_map, id) do
    response = Writer.create(db_props, as_json(doc_map), id)
    response |> handle_write_response
  end

  defp handle_write_response({status, json}) do
    {status, %{:payload => as_map(json), :headers => %{}}}
  end

  defp handle_write_response({status, json, headers}) do
    {status, %{:payload => as_map(json), :headers => as_map(headers)}}
  end

  @doc """
  Create a new document from given map with a CouchDB generated id.
  Fetching the uuid from CouchDB does of course incur a performance penalty as
  compared to providing one.
  """
  @spec create_generate(Types.db_properties, map) :: {:ok, map} | {:error, map}
  def create_generate(db_props, doc_map) do
    {:ok, uuid_json} = Reader.fetch_uuid(db_props)
    uuid = hd(Poison.decode!(uuid_json)["uuids"])
    create(db_props, doc_map, uuid)
  end

  @doc """
  Update the given document, provided it contains an id field. Raise an error
  if it does not.
  """
  @spec update(Types.db_properties, map) :: {:ok, map} | {:error, map}
  def update(db_props, doc_map) do
    case Map.fetch(doc_map, "_id") do
      {:ok, id} ->
        Writer.update(db_props, as_json(doc_map), id) |> handle_write_response
      :error ->
        raise RuntimeError, message:
          "the document to be updated must contain an \"_id\" field"
    end
  end

  @doc """
  Delete the document with the given id in the given revision.
  An error will be returned in case the document does not exist or the
  revision is wrong.
  """
  @spec destroy(Types.db_properties, String.t, String.t)
    :: {:ok, map} | {:error, map}
  def destroy(db_props, id, rev) do
    Writer.destroy(db_props, id, rev) |> handle_write_response
  end

  @doc """
  Returns everything found for the given view in the given design document.
  """
  @spec fetch_all(Types.db_properties, String.t, String.t) :: {:ok, map} | {:error, map}
  def fetch_all(db_props, design, view) do
    View.fetch_all(db_props, design, view) |> as_map
  end

  @doc """
  Find and return one document with given key in given view. Will return a
  a Map with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'update_after'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key) :: {:ok, map} | {:error, map}
  def document_by_key(db_props, view_key),
    do: document_by_key(db_props, view_key, :update_after)

  @doc """
  Find and return one document with given key in given view. Will return a
  Map with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'update_after'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key, :update_after)
    :: {:ok, map} | {:error, map}
  def document_by_key(db_props, view_key, :update_after),
    do: View.do_document_by_key(db_props, view_key, :update_after) |> as_map

  @doc """
  Find and return one document with given key in given view. Will return a
  Map with an empty list of documents if no document with given
  key exists.
  Staleness is set to 'ok'.
  """
  @spec document_by_key(Types.db_properties, Types.view_key, :ok)
    :: {:ok, map} | {:error, map}
  def document_by_key(db_props, view_key, :ok),
    do: View.do_document_by_key(db_props, view_key, :ok) |> as_map
end
