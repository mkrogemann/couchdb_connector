defmodule Couchdb.Connector.AsJsonTest do
  use ExUnit.Case

  import Couchdb.Connector.AsJson

  test "as_json/1 with valid input should encode to JSON" do
    doc_map = %{"_id" => "foo", "_rev" => "1-0f97561a543ed2e9c98a24dea818ec10", "test_key" => "test_value"}
    encoded = as_json(doc_map)

    assert encoded == "{\"test_key\":\"test_value\",\"_rev\":\"1-0f97561a543ed2e9c98a24dea818ec10\",\"_id\":\"foo\"}"
  end
end
