defmodule Couchdb.Connector.ViewTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  @retries 10

  alias Couchdb.Connector.View
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    TestPrep.ensure_view "test_view", "{\"_id\":\"_design/test_view\",\"views\":{\"test_fetch\":{\"map\":\"function(doc){emit(doc.name, doc)}\"}}}"
    TestPrep.ensure_document "{\"name\": \"test_name\"}", "test_id"
    on_exit context, fn -> TestPrep.delete_database end
  end

  test "fetch_all/3: ensure that view works as expected" do
    {:ok, json} = retry_on_error(
      fn() ->
        View.fetch_all(TestConfig.database_properties, "test_view", "test_fetch")
      end)
    {:ok, result_map} = Poison.decode json
    assert result_map["total_rows"] == 1
    [first|_] = result_map["rows"]
    assert first["value"]["name"] == "test_name"
  end

  test "create_view/3: ensure that view gets created" do
    {:ok, code} = File.read("test/resources/views/test_view.json")
    {:ok, result} = retry_on_error(
      fn() ->
        View.create_view(TestConfig.database_properties, "test_design", code)
      end)
    assert String.contains?(result, "\"id\":\"_design/test_design\"")
  end

  test "document_by_key/3: ensure that view returns document for given key" do
    result = retry(@retries,
      fn(_) ->
        View.document_by_key TestConfig.database_properties, TestConfig.test_view_key, :update_after
      end,
      fn(response) ->
        case response do
          {:ok, body} ->
            doc = Poison.decode! body
            rows = doc["rows"]
            case length(rows) do
              0 -> false
              _ -> hd(rows)["id"] == "test_id"
            end
          _ -> false
        end
      end
    )
    assert result, "document not found in view after #{@retries} tries"
  end

  test "document_by_key/3: ensure that view returns document for given integer key" do
    TestPrep.ensure_document "{\"name\": 1234}", "int_test_id"
    result = retry(@retries,
      fn(_) ->
        View.document_by_key TestConfig.database_properties, TestConfig.test_view_key(1234), :update_after
      end,
      fn(response) ->
        case response do
          {:ok, body} ->
            doc = Poison.decode! body
            rows = doc["rows"]
            case length(rows) do
              0 -> false
              _ -> hd(rows)["id"] == "int_test_id"
            end
          _ -> false
        end
      end
    )
    assert result, "document not found in view after #{@retries} tries"
  end

  test "document_by_key/3: ensure that view returns empty list of rows for missing key" do
    key = "missing"
    result = retry(@retries,
      fn(_) ->
        View.document_by_key TestConfig.database_properties, TestConfig.test_view_key(key), :update_after
      end,
      fn(response) ->
        case response do
          {:ok, body} ->
            doc = Poison.decode! body
            rows = doc["rows"]
            case length(rows) do
              0 -> false
              _ -> hd(rows)["id"] == "test_id"
            end
          _ -> false
        end
      end
    )
    assert !result, "unexpectedly received a document for key #{key}."
  end

  test "document_by_key/2: ensure that function exists. document may or may not be found" do
    View.document_by_key TestConfig.database_properties, TestConfig.test_view_key
  end

  test "document_by_key/3: ensure that function exists. document may or may not be found" do
    View.document_by_key TestConfig.database_properties, TestConfig.test_view_key, :ok
  end
end
