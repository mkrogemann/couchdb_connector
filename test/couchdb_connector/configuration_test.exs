defmodule Couchdb.Connector.ConfigurationTest do
  use ExUnit.Case

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep
  alias Couchdb.Connector.Configuration

  setup context do
    on_exit context, fn ->
      TestPrep.delete_test_admin
    end
  end

  test "server_config/3: ensure that configuration can be read from a protected server" do
    TestPrep.ensure_test_admin
    { :ok, json } = Configuration.server_config TestConfig.database_properties, "anna", "secret"
    { :ok, json_map } = Poison.decode json
    {num, _rem} = Integer.parse json_map["couch_httpd_auth"]["timeout"]
    assert is_integer num
  end
end
