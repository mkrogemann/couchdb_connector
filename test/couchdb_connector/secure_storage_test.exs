defmodule Couchdb.Connector.SecureStorageTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector.Storage
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep
  alias Couchdb.Connector.TestSupport

  setup context do
    TestPrep.delete_database
    TestPrep.ensure_test_admin

    on_exit context, fn ->
      TestPrep.delete_database
      TestPrep.delete_test_admin
    end
  end

  test "storage_up/2: ensure that database can't be created without authentication" do
    { :error, body } = Storage.storage_up TestConfig.database_properties

    assert String.contains?(body, "unauthorized")
  end

  test "storage_up/2: ensure that database can be created" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties, TestSupport.test_admin

    assert TestConfig.db_exists
  end

  test "storage_up/2: verify second attempt at creating a database returns :error" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties, TestSupport.test_admin

    { :error, body } = Storage.storage_up TestConfig.database_properties, TestSupport.test_admin

    assert String.contains?(body, "file_exists")
  end

  test "storage_down/2: ensure that database can be destroyed" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties, TestSupport.test_admin

    { :ok, _body } = Storage.storage_down TestConfig.database_properties, TestSupport.test_admin

    assert !TestConfig.db_exists
  end

  test "storage_up/2: verify second attempt at destroying a database returns :error" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties, TestSupport.test_admin
    { :ok, _body } = Storage.storage_down TestConfig.database_properties, TestSupport.test_admin

    { :error, body } = Storage.storage_down TestConfig.database_properties, TestSupport.test_admin

    assert String.contains?(body, "not_found")
  end
end
