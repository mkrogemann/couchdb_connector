defmodule Couchdb.Connector.AdminTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport

  alias Couchdb.Connector.Admin
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.UrlHelper

  setup context do
    on_exit context, fn -> remove_test_user; remove_test_admin end
  end

  test "create_user/4: ensure that a new user gets created with given parameters" do
    {:ok, body, headers} = Admin.create_user(
      TestConfig.database_properties, "jan", "relax", ["couchdb contributor"])
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "org.couchdb.user:jan"
    assert header_value(headers, "Location") ==
      UrlHelper.user_url(TestConfig.database_properties, "jan")
  end

  test "user_info/2: get public information for given username" do
    add_test_user
    {:ok, body} = Admin.user_info(TestConfig.database_properties, "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["_id"] == "org.couchdb.user:jan"
    assert body_map["roles"] == ["couchdb contributor"]
  end

  test "user_info/2: should return an error when asked for missing user" do
    {:error, body} = Admin.user_info(TestConfig.database_properties, "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "not_found"
  end

  test "destroy_user/2: ensure that a given user can be deleted" do
    add_test_user
    {:ok, body} = Admin.destroy_user(TestConfig.database_properties, "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["id"] == "org.couchdb.user:jan"
    assert String.starts_with?(body_map["rev"], "2-")
  end

  test "destroy_user/2: should return an error when given non-existing user" do
    {:error, body} = Admin.destroy_user(TestConfig.database_properties, "jan")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "not_found"
  end

  test "create_admin/3: ensure that a new admin gets created with given parameters" do
    {:ok, body, headers} = Admin.create_admin(
      TestConfig.database_properties, "anna", "secret")
    # CouchDB has a peculiar way to respond to successful 'add admin' requests
    # I think it's wrong in doing what it does, but what can you do?
    assert body == "\"\"\n"
    assert header_value(headers, "Content-Length") == "3"
  end

  test "create_admin/3: ensure that same admin cannot be created twice" do
    add_test_admin
    {:error, body, _} = Admin.create_admin(
      TestConfig.database_properties, "anna", "secret")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "unauthorized"
  end

  test "admin_info/3: ensure that an existing admin can retrieve info about herself" do
    add_test_admin
    {:ok, body} = Admin.admin_info(TestConfig.database_properties, "anna", "secret")
    assert body != ""
  end

  test "admin_info/3: should return an authorization error when a non-existing admin tries retrieve info about herself" do
    {:error, body} = Admin.admin_info(TestConfig.database_properties, "anna", "secret")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "unauthorized"
  end

  test "destroy_admin/2: ensure that a given admin can be deleted" do
    add_test_admin
    {:ok, body} = Admin.destroy_admin(TestConfig.database_properties, "anna", "secret")
    assert body != ""
  end

  test "destroy_admin/2: should return an authorization error when a non-existing admin tries to remove herself" do
    {:error, body} = Admin.destroy_admin(TestConfig.database_properties, "anna", "secret")
    {:ok, body_map} = Poison.decode body
    assert body_map["error"] == "unauthorized"
  end

  defp remove_test_user do
    case Admin.user_info(TestConfig.database_properties, "jan") do
      {:ok, body} ->
        {:ok, body_map} = Poison.decode body
        HTTPoison.delete UrlHelper.user_url(TestConfig.database_properties,"jan")
          <> "?rev=#{body_map["_rev"]}"
      {:error, _} ->
        nil
    end
  end

  defp remove_test_admin do
    case Admin.admin_info(TestConfig.database_properties, "anna", "secret") do
      {:ok, _} ->
        HTTPoison.delete UrlHelper.admin_url(TestConfig.database_properties, "anna", "secret")
      {:error, _} ->
        nil
    end
  end

  defp add_test_user do
    Admin.create_user(
      TestConfig.database_properties, "jan", "relax", ["couchdb contributor"])
  end

  defp add_test_admin do
    Admin.create_admin(TestConfig.database_properties, "anna", "secret")
  end
end
