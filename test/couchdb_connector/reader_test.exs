defmodule Couchdb.Connector.ReaderTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport

  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    TestPrep.ensure_document "{\"test_key\": \"test_value\"}", "foo"
    on_exit context, fn ->
      TestPrep.delete_database
    end
  end

  # Test cases for unsecured database

  test "get/2: ensure that document exists" do
    {:ok, json} = retry_on_error(
      fn() -> Reader.get(TestConfig.database_properties, "foo") end)
    {:ok, json_map} = Poison.decode json
    assert json_map["test_key"] == "test_value"
  end

  test "get/2: ensure an error is returned for missing document" do
    {:error, json} = retry_on_error(
      fn() -> Reader.get(TestConfig.database_properties, "unicorn") end)
    {:ok, json_map} = Poison.decode json
    assert json_map["reason"] == "missing"
  end

  test "fetch_uuid/1: get a single uuid from database server" do
    {:ok, json} = retry_on_error(
      fn() -> Reader.fetch_uuid(TestConfig.database_properties) end)
    uuid = hd(Poison.decode!(json)["uuids"])
    assert String.length(uuid) == 32
  end
end
