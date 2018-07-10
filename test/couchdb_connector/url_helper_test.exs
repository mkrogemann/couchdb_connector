defmodule Couchdb.Connector.UrlHelperTest do
  use ExUnit.Case, async: true
  doctest Couchdb.Connector.UrlHelper

  alias Couchdb.Connector.UrlHelper

  test "query_path/3 percent-encodes reserved characters" do
    url = "http://localhost/view_name"
    key = "!*'();:@&=+$,/?#[]"
    atom = :ok

    assert UrlHelper.query_path(url, key, atom) ==
      "http://localhost/view_name?key=\"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%23%5B%5D\"&stale=ok"
  end

  test "view_url/3 with args" do
    dbprops = %{protocol: "http", hostname: "localhost", port: 80, database: "myapp"}
    design = "users"
    view = "active_users"
    args = [limit: 10, skip: 5] # simulate a 5 elements page and page 2

    assert UrlHelper.view_url(dbprops, design, view, args) ==
      "http://localhost:80/myapp/_design/users/_view/active_users?limit=10&skip=5"
  end
end
