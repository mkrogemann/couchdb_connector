defmodule Couchdb.ConnectorTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

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
    {:error, err_map} = retry_on_error(
      fn() -> Connector.get(TestConfig.database_properties, "unicorn") end)
    assert err_map["reason"] == "missing"
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

  test "create/3: ensure that wrong database properties results in an error on write" do
    wrong_database_properties = %{TestConfig.database_properties | :database => "non-existing"}
    {:error, %{:headers => _headers, :payload => payload}} =
      Connector.create wrong_database_properties, %{"key" => "value"}, "42"
    assert payload["reason"] == "no_db_file"
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

  # update
  test "update/2: ensure that a document that contains an id can be updated" do
    {:ok, %{:headers => headers, :payload => _payload}} = retry_on_error(
      fn() -> Connector.create_generate(
        TestConfig.database_properties, %{"key" => "original value"})
      end)
    id = id_from_url(headers["Location"])
    {:ok, reloaded} = Connector.get(TestConfig.database_properties, id)
    updated = %{reloaded | "key" => "new value"}
    {:ok, %{:headers => headers, :payload => _payload}} = retry_on_error(fn() ->
      Connector.update(TestConfig.database_properties, updated)
    end)
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "update/2: verify that a document without id raises an exception" do
    update = %{"_rev" => "some_revision", "key" => "new value"}
    assert_raise RuntimeError, fn ->
      Connector.update(TestConfig.database_properties, update)
    end
  end

  # destroy
  test "destroy/3: ensure that a document with given id can be deleted" do
    {:ok, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.create(TestConfig.database_properties, %{"key" => "value"}, "42")
    end)
    revision = payload["rev"]
    {:ok, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.destroy(TestConfig.database_properties, "42", revision)
    end)
    assert String.starts_with?(payload["rev"], "2-")
    {:error, %{"error" => "not_found", "reason" => "deleted"}} =
      Connector.get(TestConfig.database_properties, "42")
  end

  test "destroy/3: attempting to delete a non-existing document triggers an error" do
    {:error, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.destroy(TestConfig.database_properties, "42", "any_rev")
    end)
    assert payload["reason"] == "missing"
  end

  # tests for secured database
  test "fetch_uuid/1: get a single uuid from a secured database server" do
    TestPrep.secure_database
    {:ok, uuid_map} = retry_on_error(fn() ->
      Connector.fetch_uuid(TestConfig.database_properties)
    end)
    uuid = hd(uuid_map["uuids"])
    assert String.length(uuid) == 32
  end

  test "get/2: ensure that document exists using basic authentication" do
    TestPrep.secure_database
    {:ok, doc_map} = retry_on_error(fn() ->
      Connector.get(Map.merge(TestConfig.database_properties, TestConfig.test_user), "foo")
    end)
    assert doc_map["test_key"] == "test_value"
  end

  # create with auth
  test "create/4: ensure that a new document gets created with given id for given user" do
    TestPrep.secure_database
    {:ok, doc_map} = Poison.decode("{\"key\": \"value\"}")
    {:ok, %{:headers => headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.create(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), doc_map, "42")
      end)
    assert payload["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  # create with generated uuid and auth
  test "create_generate/3: ensure that a new document gets created with a fetched id for given user" do
    TestPrep.secure_database
    {:ok, doc_map} = Poison.decode("{\"key\": \"value\"}")
    {:ok, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.create_generate(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), doc_map)
      end)
    assert String.length(payload["id"]) == 32
    assert String.starts_with?(payload["rev"], "1-")
  end

  # update with auth
  test "update/3: ensure that a document that contains an id can be updated" do
    TestPrep.secure_database
    {:ok, %{:headers => headers, :payload => _payload}} = retry_on_error(fn() ->
      Connector.create_generate(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), %{"key" => "original value"})
      end)
    id = id_from_url(headers["Location"])
    {:ok, reloaded} = Connector.get(Map.merge(TestConfig.database_properties, TestConfig.test_user), id)
    updated = %{reloaded | "key" => "new value"}
    {:ok, %{:headers => headers, :payload => _payload}} = retry_on_error(fn() ->
      Connector.update(Map.merge(TestConfig.database_properties, TestConfig.test_user), updated)
    end)
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "update/3: verify that a document without id raises an exception" do
    TestPrep.secure_database
    update = %{"_rev" => "some_revision", "key" => "new value"}
    assert_raise RuntimeError, fn ->
      Connector.update(Map.merge(TestConfig.database_properties, TestConfig.test_user), update)
    end
  end

  # destroy with auth
  test "destroy/3: ensure that a document with given id can be deleted with authentication" do
    TestPrep.secure_database
    {:ok, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.create(Map.merge(TestConfig.database_properties, TestConfig.test_user), %{"key" => "value"}, "42")
    end)
    revision = payload["rev"]
    {:ok, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.destroy(Map.merge(TestConfig.database_properties, TestConfig.test_user), "42", revision)
    end)
    assert String.starts_with?(payload["rev"], "2-")
    {:error, %{"error" => "not_found", "reason" => "deleted"}} =
      Connector.get(Map.merge(TestConfig.database_properties, TestConfig.test_user), "42")
  end

  test "destroy/3: attempting to delete a non-existing document triggers an error with authentication" do
    TestPrep.secure_database
    {:error, %{:headers => _headers, :payload => payload}} = retry_on_error(fn() ->
      Connector.destroy(Map.merge(TestConfig.database_properties, TestConfig.test_user), "42", "any_rev")
    end)
    assert payload["reason"] == "missing"
  end
end
