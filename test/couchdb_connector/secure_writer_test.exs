defmodule Couchdb.Connector.SecureWriterTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector.Writer
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    on_exit context, fn ->
      TestPrep.delete_test_user
      TestPrep.delete_test_admin
      TestPrep.delete_database
    end
  end

  # Tests for secured database, using basic authentication

  test "create/4: ensure that a new document gets created with given id" do
    TestPrep.secure_database
    {:ok, body, headers} = retry_on_error(
      fn() -> Writer.create(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), "{\"key\": \"value\"}", "42")
      end)
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "42"
    assert id_from_url(header_value(headers, "Location")) == "42"
  end

  test "create_generate/3: ensure that a new document gets create with a fetched id" do
    TestPrep.secure_database
    {:ok, body, _headers} = retry_on_error(
      fn() -> Writer.create_generate(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), "{\"key\": \"value\"}")
      end)
    {:ok, body_map} = Poison.decode body
    assert String.starts_with?(body_map["rev"], "1-")
    assert String.length(body_map["id"]) == 32
  end

  test "update/3: ensure that a document that contains an existing id can be updated" do
    TestPrep.secure_database
    {:ok, _body, headers} = retry_on_error(
      fn() ->
        Writer.create_generate(
          Map.merge(TestConfig.database_properties, TestConfig.test_user), "{\"key\": \"original value\"}")
      end)
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"#{id}\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    {:ok, _body, headers} = retry_on_error(
      fn() ->
        Writer.update(Map.merge(TestConfig.database_properties, TestConfig.test_user), update)
      end)
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "update/3: verify that a document without id raises an exception" do
    update = "{\"_rev\": \"some_revision\", \"key\": \"new value\"}"
    assert_raise RuntimeError, fn ->
      Writer.update(Map.merge(TestConfig.database_properties, TestConfig.test_user), update)
    end
  end

  test "update/4: ensure that an existing document with given id can be updated" do
    TestPrep.secure_database
    {:ok, _body, headers} = retry_on_error(
      fn() -> Writer.create_generate(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), "{\"key\": \"original value\"}")
      end)
    id = id_from_url(header_value(headers, "Location"))
    revision = header_value(headers, "ETag")
    update = "{\"_id\": \"#{id}\", \"_rev\": #{revision}, \"key\": \"new value\"}"
    {:ok, _body, headers} = retry_on_error(
      fn() -> Writer.update(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), update, id)
      end)
    assert String.starts_with?(header_value(headers, "ETag"), "\"2-")
  end

  test "destroy/4: ensure that document with given id can be deleted" do
    TestPrep.secure_database
    {:ok, _, headers} = retry_on_error(
      fn() -> Writer.create(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), "{\"key\": \"value\"}", "42")
      end)
    revision = String.replace(header_value(headers, "ETag"), "\"", "")
    {:ok, body} = retry_on_error(
      fn() -> Writer.destroy(
        Map.merge(TestConfig.database_properties, TestConfig.test_user), "42", revision)
      end)
    {:ok, body_map} = Poison.decode body
    assert String.starts_with?(body_map["rev"], "2-")
    {:error, _} = Reader.get(TestConfig.database_properties, "42")
  end
end
