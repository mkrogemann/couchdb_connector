defmodule Couchdb.Connector.AdminTest do
  use ExUnit.Case

  alias Couchdb.Connector.Admin
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.UrlHelper

  setup context do
    on_exit context, fn -> remove_test_user end
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

  defp remove_test_user do
    case Admin.user_info(TestConfig.database_properties, "jan") do
      {:ok, body} ->
        {:ok, body_map} = Poison.decode body
        HTTPoison.delete UrlHelper.user_url(TestConfig.database_properties,"jan")
        <> "?rev=#{body_map["_rev"]}"
      {:error, _} -> nil
    end
  end

  defp add_test_user do
    Admin.create_user(
      TestConfig.database_properties, "jan", "relax", ["couchdb contributor"])
  end

  defp header_value headers, key do
    Enum.into(headers, %{})[key]
  end
end
