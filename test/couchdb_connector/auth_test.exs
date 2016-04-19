defmodule Couchdb.Connector.AuthTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep
  alias Couchdb.Connector.AuthSupport

  setup context do
    on_exit context, fn -> TestPrep.delete_test_user end
  end

  test "with_user_auth/1: should return URL with basic auth credentials if basic auth is configured" do
    import Couchdb.Connector.Auth
    db_props = Couchdb.Connector.Configuration.get[:connector]
    assert with_user_auth(db_props) == "http://jan:relax@127.0.0.1:5984"
  end

  test "authenticate_basic/1: should build a database server URL with basic auth credentials" do
    db_props = Couchdb.Connector.Configuration.get[:connector]
    assert AuthSupport.authenticate_basic(db_props) == "http://jan:relax@127.0.0.1:5984"
  end

  test "authenticate_none/1: should build a database server URL with no authentication information" do
    db_props = TestConfig.database_properties
    assert AuthSupport.authenticate_none(db_props) == "http://127.0.0.1:5984"
  end
end
