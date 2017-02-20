defmodule Couchdb.Connector.WriterTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector.Writer
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    on_exit context, fn ->
      TestPrep.delete_database
    end
  end

  # Test cases for unsecured database

  test "create/3: ensure that a new document gets created with given id" do
    {:ok, body, headers} = retry_on_error(
      fn() ->
        Writer.create(TestConfig.database_properties, "{\"key\": \"value\"}", "42")
      end)
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  test "create/3: ensure that wrong database properties results in an error on write" do
    wrong_database_properties = %{TestConfig.database_properties | :database => "non-existing"}
    {:error, body, _headers} = Writer.create wrong_database_properties, "{\"key\": \"value\"}", "42"
    {:ok, body_map} = Poison.decode body
    assert body_map["reason"] == "no_db_file"
  end

  test "create/3: ensure that given id overrides id contained in document" do
    {:ok, response_body, headers} = retry_on_error(
      fn() ->
        Writer.create(
          TestConfig.database_properties, "{\"_id\": \"some_id\", \"key\": \"value\"}", "42")
      end)
    response_map = Poison.decode! response_body
    assert response_map["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  test "create_generate/2: ensure that a new document gets created with a fetched id" do
    {:ok, body, _headers} = retry_on_error(
      fn() ->
        Writer.create_generate(TestConfig.database_properties, "{\"key\": \"value\"}")
      end)
    {:ok, body_map} = Poison.decode body
    assert String.starts_with?(body_map["rev"], "1-")
    assert String.length(body_map["id"]) == 32
  end

  test "update/2: ensure that a document that contains an existing id can be updated" do
    {:ok, _body, headers} = retry_on_error(
      fn() -> Writer.create_generate(
        TestConfig.database_properties, "{\"key\": \"original value\"}")
      end)
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"#{id}\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    {:ok, _body, headers} = retry_on_error(
      fn() -> Writer.update(TestConfig.database_properties, update) end)
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "update/2: verify that a document without id raises an exception" do
    update = "{\"_rev\": \"some_revision\", \"key\": \"new value\"}"
    assert_raise RuntimeError, fn ->
      Writer.update(TestConfig.database_properties, update)
    end
  end

  test "update/3: ensure that an existing document with given id can be updated" do
    {:ok, _body, headers} = retry_on_error(fn() ->
      Writer.create_generate(TestConfig.database_properties, "{\"key\": \"original value\"}")
    end)
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"#{id}\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    {:ok, _body, headers} = retry_on_error(fn() ->
      Writer.update(TestConfig.database_properties, update, id)
    end)
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "destroy/3: ensure that document with given id can be deleted" do
    {:ok, _, headers} = retry_on_error(
      fn() -> Writer.create(TestConfig.database_properties, "{\"key\": \"value\"}", "42") end)
    revision = String.replace(header_value(headers, "ETag"), "\"", "")
    {:ok, body} = retry_on_error(
      fn() -> Writer.destroy(TestConfig.database_properties, "42", revision) end)
    {:ok, body_map} = Poison.decode body
    assert String.starts_with?(body_map["rev"], "2-")
    {:error, _} = Reader.get(TestConfig.database_properties, "42")
  end

  test "destroy/3: attempting to delete a non-existing document triggers an error" do
    {:error, body} = retry_on_error(
      fn() -> Writer.destroy(TestConfig.database_properties, "42", "any_rev") end)
    {:ok, body_map} = Poison.decode body
    assert body_map["reason"] == "missing"
  end

  test "destroy/3: attempting to delete a document with wrong revision triggers an error" do
    {:ok, _, headers} = retry_on_error(
      fn() -> Writer.create(TestConfig.database_properties, "{\"key\": \"value\"}", "42") end)
    revision = String.replace(String.replace(header_value(headers, "ETag"), "\"", ""), "1-", "2-")
    {:error, body} = retry_on_error(
      fn() -> Writer.destroy(TestConfig.database_properties, "42", revision) end)
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "conflict"
  end
end
