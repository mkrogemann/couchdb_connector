defmodule Couchdb.Connector.AdminTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  alias Couchdb.Connector.Admin
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep
  alias Couchdb.Connector.UrlHelper

  setup context do
    on_exit context, fn ->
      TestPrep.delete_test_user
      TestPrep.delete_test_admin
      TestPrep.delete_database
    end
  end

  test "create_user/3: ensure that a new user gets created with given parameters" do
    TestPrep.ensure_test_admin
    {:ok, body, headers} = Admin.create_user(
      Map.merge(TestConfig.database_properties, TestConfig.test_admin), TestConfig.test_user, ["couchdb contributor"])
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "org.couchdb.user:jan"
    assert header_value(headers, "Location") == UrlHelper.user_url(TestConfig.database_properties, "jan")
  end

  test "user_info/2: get public information for given username" do
    TestPrep.ensure_test_admin
    TestPrep.ensure_test_user
    {:ok, body} = Admin.user_info(Map.merge(TestConfig.database_properties, TestConfig.test_admin), "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["_id"] == "org.couchdb.user:jan"
    assert body_map["roles"] == ["members"]
  end

  test "user_info/2: should return an error when asked for missing user" do
    TestPrep.ensure_test_admin
    {:error, body} = Admin.user_info(Map.merge(TestConfig.database_properties, TestConfig.test_admin), "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "not_found"
  end

  test "destroy_user/2: ensure that a given user can be deleted" do
    TestPrep.ensure_test_admin
    TestPrep.ensure_test_user
    {:ok, body} = Admin.destroy_user(Map.merge(TestConfig.database_properties, TestConfig.test_admin), "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "org.couchdb.user:jan"
    assert String.starts_with?(body_map["rev"], "2-")
  end

  test "destroy_user/2: should return an error when given non-existing user" do
    TestPrep.ensure_test_admin
    {:error, body} = Admin.destroy_user(Map.merge(TestConfig.database_properties, TestConfig.test_admin), "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "not_found"
  end

  test "create_admin/2: ensure that a new admin gets created with given parameters" do
    {:ok, body, headers} = Admin.create_admin(
      TestConfig.database_properties, TestConfig.test_admin)
    # CouchDB has a peculiar way to respond to successful 'add admin' requests
    # I think it's wrong in doing what it does, but what can you do?
    assert body == "\"\"\n"
    assert header_value(headers, "Content-Length") == "3"
  end

  test "create_admin/2: ensure that same admin cannot be created twice" do
    TestPrep.ensure_test_admin
    {:error, body, _} = Admin.create_admin(
      TestConfig.database_properties, TestConfig.test_admin)
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "unauthorized"
  end

  test "admin_info/1: ensure that an existing admin can retrieve info about herself" do
    TestPrep.ensure_test_admin
    {:ok, body} = Admin.admin_info(Map.merge(TestConfig.database_properties, TestConfig.test_admin))
    assert body != ""
  end

  test "admin_info/1: should return an authorization error when a non-existing admin tries retrieve info about herself" do
    {:error, body} = Admin.admin_info(Map.merge(TestConfig.database_properties, TestConfig.test_admin))
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "unauthorized"
  end

  test "destroy_admin/2: ensure that a given admin can be deleted" do
    TestPrep.ensure_test_admin
    {:ok, body} = Admin.destroy_admin(TestConfig.database_properties, "anna", "secret")
    assert body != ""
  end

  test "destroy_admin/2: should return an authorization error when a non-existing admin tries to remove herself" do
    {:error, body} = Admin.destroy_admin(TestConfig.database_properties, "anna", "secret")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "unauthorized"
  end

  test "set_security/3: ensure that the security object can be set for the given database" do
    TestPrep.ensure_database
    TestPrep.ensure_test_admin
    TestPrep.ensure_test_user
    {:ok, body} = Admin.set_security(Map.merge(TestConfig.database_properties, TestConfig.test_admin), ["anna"], ["jan"])
    assert body == "{\"ok\":true}\n"
  end
end
