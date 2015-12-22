defmodule Couchdb.Connector.ReaderTest do
  use ExUnit.Case

  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    TestPrep.ensure_document "{\"test_key\": \"test_value\"}", "foo"
    on_exit context, fn -> TestPrep.delete_database end
  end

  test "get/2: ensure that document exists" do
    { :ok, json } = Reader.get TestConfig.database_properties, "foo"
    { :ok, json_map } = Poison.decode json
    assert json_map["test_key"] == "test_value"
  end

  test "get/2: ensure an error is returned for missing document" do
    { :error, json } = Reader.get TestConfig.database_properties, "unicorn"
    { :ok, json_map } = Poison.decode json
    assert json_map["reason"] == "missing"
  end

  test "fetch_uuid/1: get a single uuid from database server" do
    { :ok, json } = Reader.fetch_uuid(TestConfig.database_properties)
    uuid = hd(Poison.decode!(json)["uuids"])
    assert String.length(uuid) == 32
  end
end
