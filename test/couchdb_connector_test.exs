defmodule Couchdb.ConnectorTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep
  alias Couchdb.Connector.TestSupport

  setup context do
    TestPrep.ensure_database
    TestPrep.ensure_document "{\"test_key\": \"test_value\"}", "foo"
    on_exit context, fn ->
      TestPrep.delete_test_user
      TestPrep.delete_test_admin
      TestPrep.delete_database
    end
  end

  test "fetch_uuid/1: get a single uuid from database server" do
    {:ok, uuid_map} = retry_on_error(
      fn() -> Connector.fetch_uuid(TestConfig.database_properties) end)
    uuid = hd(uuid_map["uuids"])
    assert String.length(uuid) == 32
  end

  # tests for unsecured database
  test "get/2: ensure that document exists" do
    {:ok, doc_map} = retry_on_error(
      fn() -> Connector.get(TestConfig.database_properties, "foo") end)
    assert doc_map["test_key"] == "test_value"
  end

  test "get/2: ensure an error is returned for missing document" do
    {:error, json} = retry_on_error(
      fn() -> Connector.get(TestConfig.database_properties, "unicorn") end)
    {:ok, json_map} = Poison.decode json
    assert json_map["reason"] == "missing"
  end

  # create
  test "create/3: ensure that a new document gets created with given id" do
    {:ok, doc_map} = Poison.decode("{\"key\": \"value\"}")
    {:ok, %{:headers => headers, :payload => payload}} = retry_on_error(
      fn() ->
        Connector.create(TestConfig.database_properties, doc_map, "42")
      end)
    assert payload["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  # create with generated uuid
  test "create_generate/2: ensure that a new document gets created with a fetched id" do
    {:ok, doc_map} = Poison.decode("{\"key\": \"value\"}")
    {:ok, %{:headers => _headers, :payload => payload}} = retry_on_error(
      fn() ->
        Connector.create_generate(TestConfig.database_properties, doc_map)
      end)
    assert String.length(payload["id"]) == 32
    assert String.starts_with?(payload["rev"], "1-")
  end

  # tests for secured database
  test "fetch_uuid/1: get a single uuid from a secured database server" do
    TestPrep.secure_database
    {:ok, uuid_map} = retry_on_error(
      fn() ->
        Connector.fetch_uuid(TestConfig.database_properties)
      end)
    uuid = hd(uuid_map["uuids"])
    assert String.length(uuid) == 32
  end

  test "get/3: ensure that document exists using basic authentication" do
    TestPrep.secure_database
    {:ok, doc_map} = retry_on_error(
      fn() ->
        Connector.get(TestConfig.database_properties, TestSupport.test_user, "foo")
      end)
    assert doc_map["test_key"] == "test_value"
  end

  # create with auth
  test "create/4: ensure that a new document gets created with given id for given user" do
    TestPrep.secure_database
    {:ok, doc_map} = Poison.decode("{\"key\": \"value\"}")
    {:ok, %{:headers => headers, :payload => payload}} = retry_on_error(
      fn() -> Connector.create(
        TestConfig.database_properties, TestSupport.test_user, doc_map, "42")
      end)
    assert payload["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  # create with generated uuid and auth
  test "create_generate/3: ensure that a new document gets created with a fetched id for given user" do
    TestPrep.secure_database
    {:ok, doc_map} = Poison.decode("{\"key\": \"value\"}")
    {:ok, %{:headers => headers, :payload => payload}} = retry_on_error(
      fn() -> Connector.create_generate(
        TestConfig.database_properties, TestSupport.test_user, doc_map)
      end)
    assert String.length(payload["id"]) == 32
    assert String.starts_with?(payload["rev"], "1-")
  end

  # update with auth

end
