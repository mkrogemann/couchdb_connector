defmodule Couchdb.ConnectorViewTest do
  use ExUnit.Case
  use Couchdb.Connector.TestSupport.Macros

  @retries 10

  alias Couchdb.Connector
  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.TestPrep

  setup context do
    TestPrep.ensure_database
    TestPrep.ensure_view "test_view", "{\"_id\":\"_design/test_view\",\"views\":{\"test_fetch\":{\"map\":\"function(doc){emit(doc.name, doc)}\"}}}"
    TestPrep.ensure_document "{\"name\": \"test_name\"}", "test_id"
    on_exit context, fn ->
      TestPrep.delete_test_user
      TestPrep.delete_test_admin
      TestPrep.delete_database
    end
  end

  test "document_by_key/3: ensure that view returns document for given key" do
    result = retry(@retries,
      fn(_) ->
        Connector.document_by_key(TestConfig.database_properties, TestConfig.test_view_key, :update_after)
      end,
      fn(response) ->
        case response do
          {:ok, doc_map} ->
            rows = doc_map["rows"]
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

  test "document_by_key/3: ensure that view returns empty list of rows for missing key" do
    key = "missing"
    result = retry(@retries,
      fn(_) ->
        Connector.document_by_key(TestConfig.database_properties, TestConfig.test_view_key(key), :update_after)
      end,
      fn(response) ->
        case response do
          {:ok, doc_map} ->
            rows = doc_map["rows"]
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

  test "fetch_all/3: ensure that view works as expected" do
    {:ok, result_map} = retry_on_error(
      fn() ->
        Connector.fetch_all(TestConfig.database_properties, "test_view", "test_fetch")
      end)
    assert result_map["total_rows"] == 1
    [first|_] = result_map["rows"]
    assert first["value"]["name"] == "test_name"
  end

  test "fetch_all/3: ensure that view works as expected with authentication" do
    TestPrep.secure_database()
    {:ok, result_map} = retry_on_error(
      fn() ->
        Connector.fetch_all(Map.merge(TestConfig.database_properties, TestConfig.test_user), "test_view", "test_fetch")
      end)
    assert result_map["total_rows"] == 1
    [first|_] = result_map["rows"]
    assert first["value"]["name"] == "test_name"
  end

  test "document_by_key/2: ensure that function exists. document may or may not be found" do
    Connector.document_by_key(TestConfig.database_properties, TestConfig.test_view_key)
  end

  test "document_by_key/3: ensure that function exists. document may or may not be found" do
    Connector.document_by_key(TestConfig.database_properties, TestConfig.test_view_key, :ok)
  end
end
