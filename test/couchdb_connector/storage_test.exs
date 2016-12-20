defmodule Couchdb.Connector.StorageTest do
  use ExUnit.Case

  alias Couchdb.Connector.Storage
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.delete_database
    on_exit context, fn -> TestPrep.delete_database end
  end

  test "storage_up/1: ensure that database can be created" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties

    assert TestConfig.db_exists
  end

  test "storage_up/1: verify second attempt at creating a database returns :error" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties

    { :error, body } = Storage.storage_up TestConfig.database_properties

    assert String.contains?(body, "file_exists")
  end

  test "storage_down/1: ensure that database can be destroyed" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties

    { :ok, _body } = Storage.storage_down TestConfig.database_properties

    assert !TestConfig.db_exists
  end

  test "storage_up/1: verify second attempt at destroying a database returns :error" do
    { :ok, _body } = Storage.storage_up TestConfig.database_properties
    { :ok, _body } = Storage.storage_down TestConfig.database_properties

    { :error, body } = Storage.storage_down TestConfig.database_properties

    assert String.contains?(body, "not_found")
  end
end
