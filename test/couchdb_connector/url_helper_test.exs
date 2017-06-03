defmodule Couchdb.Connector.UrlHelperTest do
  use ExUnit.Case, async: true
  doctest Couchdb.Connector.UrlHelper

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

    setup context do
      TestPrep.ensure_database
      TestPrep.ensure_document "{\"test_key\": \"test_value\"}", "foo"
      on_exit context, fn ->
        TestPrep.delete_database
      end
    end

  test "query_path/3 percent-encodes reserved characters" do
    url = "http://localhost/view_name"
    key = "!*'();:@&=+$,/?#[]"
    atom = :ok

    assert UrlHelper.query_path(url, key, atom) ==
      "http://localhost/view_name?key=\"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%23%5B%5D\"&stale=ok"
  end

  test "attachment_insert_url/4 properly produces insertion url" do
    db = Application.get_env(:couchdb_connector, :database)
    myurl = "http://127.0.0.1:5984/#{db}/dog?rev=a-3" 
    assert myurl = UrlHelper.attachment_insert_url(
                     TestConfig.database_properties, db , "dog", "a-3")
  end

  test "attachment_fetch_url/3: properly produces an attachment fetch url" do
    db = Application.get_env(:couchdb_connector, :database)
    myurl = "http://127.0.0.1:5984/#{db}/dog?rev=a-4" 
    assert myurl = UrlHelper.attachment_fetch_url(
                     TestConfig.database_properties, db, "dog", "a-4")
  end
end
