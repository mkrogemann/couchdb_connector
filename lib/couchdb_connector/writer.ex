defmodule Couchdb.Connector.Writer do
  @moduledoc false

  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  def create db_props, json do
    { :ok, uuid_json } = Reader.fetch_uuid(db_props)
    uuid = hd(Poison.decode!(uuid_json)["uuids"])
    create db_props, json, uuid
  end

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
    cond do
      doc_map["_id"] == id ->
        doc_map
      doc_map["_id"] != id ->
        raise RuntimeError, message:
          "id mismatch: URL id #{id} and document _id #{doc_map["_id"]} differ"
    end
  end
end
