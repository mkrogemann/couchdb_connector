defmodule Couchdb.Connector.Writer do
  @moduledoc """
  The Writer module provides functions to create and update documents in
  the CouchDB database given by the database properties.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.Storage.storage_up(db_props)
      {:ok, "{\\"ok\\":true}\\n"}

      Couchdb.Connector.Writer.create(db_props, "{\\"key\\": \\"value\\"}")
      {:ok, "{\\"ok\\":true,\\"id\\":\\"7dd00...\\",\\"rev\\":\\"1-59414e7...\\"}\\n",
            [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
             {"Location", "http://localhost:5984/couchdb_connector_test/7dd00..."},
             {"ETag", "\\"1-59414e7...\\""}, {"Date", "Mon, 21 Dec 2015 16:13:23 GMT"},
             {"Content-Type", "text/plain; charset=utf-8"},
             {"Content-Length", "95"}, {"Cache-Control", "must-revalidate"}]}

  """

  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Create a new document with given json and a CouchDB generated id.
  This function maps to a HTTP PUT.
  Fetching the uuid from CouchDB does incur a performance penalty as
  compared to providing one and using create/3.
  """
  def create db_props, json do
    { :ok, uuid_json } = Reader.fetch_uuid(db_props)
    uuid = hd(Poison.decode!(uuid_json)["uuids"])
    create db_props, json, uuid
  end

  @doc """
  Create a new document with given json and given id. Clients must make sure
  that the id has not been used for an existing document in CouchDB.
  Either provide a UUID or consider using create/2 in case uniqueness cannot
  be guaranteed.
  """
  def create db_props, json, id do
    db_props
    |> UrlHelper.document_url(id)
    |> do_create(json, id)
    |> Handler.handle_put(_include_headers = true)
  end

  defp do_create url, json, _id do
    couchdb_safe_json = Poison.Parser.parse!(json)
    |> couchdb_safe
    |> Poison.encode!
    HTTPoison.put! url, couchdb_safe_json, [ Headers.json_header ]
  end

  defp couchdb_safe map do
    case Map.get(map, "_id") do
      nil -> Map.delete(map, "_id")
      _ -> map
    end
  end

  @doc """
  Update the given document. Note that an _id field must be contained in the
  document. A missing _id field with trigger a RuntimeError.
  """
  def update db_props, json do
    doc_map = Poison.Parser.parse!(json)
    id = Map.fetch(doc_map, "_id")
    case id do
      { :ok, id } ->
        UrlHelper.document_url(db_props, id)
        |> do_update(doc_map)
        |> Handler.handle_put(_include_headers = true)
      :error ->
        raise RuntimeError, message:
          "the document to be updated must contain an \"_id\" field"
    end
  end

  defp do_update url, doc_map do
    HTTPoison.put! url, Poison.encode!(doc_map), [ Headers.json_header ]
  end

  @doc """
  Update the given document that is stored under the given id. Note that
  a mismatch between the id parameter and the _id field contained in the
  document will trigger a RuntimeError.
  """
  def update db_props, json, id do
    db_props
    |> UrlHelper.document_url(id)
    |> do_update(json, id)
    |> Handler.handle_put(_include_headers = true)
  end

  defp do_update url, json, id do
    id_checked_json = Poison.Parser.parse!(json)
    |> check_id(id)
    |> Poison.encode!
    HTTPoison.put!(url, id_checked_json, [ Headers.json_header ])
  end

  defp check_id doc_map, id do
    case doc_map["_id"] do
      doc_id when doc_id == id ->
        doc_map
      _ ->
        raise RuntimeError, message:
          "id mismatch: URL id #{id} and document _id #{doc_map["_id"]} differ"
    end
  end
end
