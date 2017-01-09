defmodule Couchdb.Connector.SecureStorageTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector.Storage
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.delete_database
    TestPrep.ensure_test_admin

    on_exit context, fn ->
      TestPrep.delete_database
      TestPrep.delete_test_admin
    end
  end

  test "storage_up/1: ensure that database can't be created without authentication" do
    { :error, body } = TestConfig.database_properties |> Storage.storage_up

    assert String.contains?(body, "unauthorized")
  end

  test "storage_up/1: ensure that database can be created" do
    { :ok, _body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_up

    assert TestConfig.db_exists
  end

  test "storage_up/1: verify second attempt at creating a database returns :error" do
    { :ok, _body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_up

    { :error, body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_up

    assert String.contains?(body, "file_exists")
  end

  test "storage_down/1: ensure that database can be destroyed" do
    { :ok, _body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_up

    { :ok, _body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_down

    assert !TestConfig.db_exists
  end

  test "storage_down/1: verify second attempt at destroying a database returns :error" do
    { :ok, _body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_up
    { :ok, _body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_down

    { :error, body } = Map.merge(TestConfig.database_properties, TestConfig.test_admin) |> Storage.storage_down

    assert String.contains?(body, "not_found")
  end
end
