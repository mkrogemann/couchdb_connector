defmodule Couchdb.Connector.AsMapTest do
  use ExUnit.Case

  import AsMap

  test "as_map/2 with invalid json string should raise RuntimeError" do
    invalid = "{\"_id\":\"foo\",\"_rev\":\"1-0f97561a543ed2e9c98a24dea818ec10\",test_key\":\"test_value\"}\n"

    assert_raise(RuntimeError, """
    Document returned by CouchDB is invalid
    token: t
    json: {"_id":"foo","_rev":"1-0f97561a543ed2e9c98a24dea818ec10",test_key":"test_value"}\n
    """, fn -> as_map(invalid) end)
  end

  test "as_map/2 with empty string should raise RuntimeError" do
    empty = ""

    assert_raise(RuntimeError, """
    Document returned by CouchDB is invalid
    json: #{empty}
    """,
    fn -> as_map(empty) end)
  end

  test "as_map/2 with valid json string should return decoded Map" do
    valid = "{\"_id\":\"foo\",\"_rev\":\"1-0f97561a543ed2e9c98a24dea818ec10\",\"test_key\":\"test_value\"}\n"
    decoded = as_map(valid)
    
    assert decoded["_id"] == "foo"
    assert decoded["_rev"] == "1-0f97561a543ed2e9c98a24dea818ec10"
    assert decoded["test_key"] == "test_value"
  end
end
