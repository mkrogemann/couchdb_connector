defmodule Couchdb.Connector.ConfigurationTest do
  use ExUnit.Case

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep
  alias Couchdb.Connector.Configuration

  setup context do
    TestPrep.ensure_test_admin
    on_exit context, fn ->
      TestPrep.delete_test_admin
    end
  end

  test "start_link/0: should start and register a configuration Agent process" do
    assert Configuration.start_link
    pid = Process.whereis :couchdb_config
    assert Process.alive? pid
  end

  test "get/0: should return the configuration Map" do
    Configuration.start_link
    assert Configuration.get[:server]["couch_httpd_auth"]["timeout"]
  end

  test "server_config/3: ensure that configuration can be read from a protected server" do
    { :ok, json } = Configuration.server_config TestConfig.database_properties, "anna", "secret"
    { :ok, json_map } = Poison.decode json
    {num, _rem} = Integer.parse json_map["couch_httpd_auth"]["timeout"]
    assert is_integer num
  end
end
