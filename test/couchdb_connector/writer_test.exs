defmodule Couchdb.Connector.WriterTest do
  use ExUnit.Case

  alias Couchdb.Connector.Writer
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    on_exit context, fn -> TestPrep.delete_database end
  end

  test "create/3: ensure that a new document gets created with given id" do
    {:ok, body, headers} = Writer.create TestConfig.database_properties, "{\"key\": \"value\"}", "42"
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  test "create/3: ensure that given id overrides id contained in document" do
    {:ok, response_body, headers} = Writer.create TestConfig.database_properties, "{\"_id\": \"some_id\", \"key\": \"value\"}", "42"
    response_map = Poison.decode! response_body
    assert response_map["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  test "create/2: ensure that a new document gets create with a fetched id" do
    {:ok, body, _headers} = Writer.create TestConfig.database_properties, "{\"key\": \"value\"}"
    {:ok, body_map} = Poison.decode body
    assert String.starts_with?(body_map["rev"], "1-")
    assert String.length(body_map["id"]) == 32
  end

  test "update/2: ensure that a document that contains an existing id can be updated" do
    {:ok, _body, headers} = Writer.create TestConfig.database_properties, "{\"key\": \"original value\"}"
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"#{id}\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    {:ok, _body, headers} = Writer.update TestConfig.database_properties, update
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "update/2: verify that a document without id raises an exception" do
    update = "{\"_rev\": \"some_revision\", \"key\": \"new value\"}"
    assert_raise RuntimeError, fn ->
      Writer.update(TestConfig.database_properties, update)
    end
  end

  test "update/3: ensure that an existing document with given id can be updated" do
    {:ok, _body, headers} = Writer.create TestConfig.database_properties, "{\"key\": \"original value\"}"
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"#{id}\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    {:ok, _body, headers} = Writer.update TestConfig.database_properties, update, id
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "update/3: verify that a mismatch of document id and URL id raises an exception" do
    {:ok, _body, headers} = Writer.create TestConfig.database_properties, "{\"key\": \"original value\"}"
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"some_wrong_id\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    assert_raise RuntimeError, fn ->
      Writer.update TestConfig.database_properties, update, id
    end
  end

  defp header_value headers, key do
    Enum.into(headers, %{})[key]
  end

  defp id_from_url url do
    hd(Enum.reverse(String.split(url, "/", trim: true)))
  end
end
