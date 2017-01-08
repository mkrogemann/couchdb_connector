defmodule Couchdb.Connector.TestPrep do
  alias Couchdb.Connector.TestSupport

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Admin
  alias Couchdb.Connector.UrlHelper

  def ensure_database do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.put "#{TestConfig.database_url()}", "{}", [Headers.json_header]
    end)
  end

  def delete_database do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.delete("#{TestConfig.database_url()}")
    end)
  end

  def ensure_document(doc, id) do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.put "#{TestConfig.database_url()}/#{id}", doc, [Headers.json_header]
    end)
  end

  def ensure_view(design_name, code) do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.put "#{TestConfig.database_url()}/_design/#{design_name}", code, [Headers.json_header]
    end)
  end

  def ensure_test_user do
    TestSupport.retry_on_error(fn() ->
      Admin.create_user(Map.merge(TestConfig.database_properties(), TestConfig.test_admin()), TestConfig.test_user(), ["members"])
    end)
  end

  def delete_test_user do
    case Admin.user_info(Map.merge(TestConfig.database_properties(), TestConfig.test_admin()), "jan") do
      {:ok, body} ->
        {:ok, body_map} = Poison.decode body
        HTTPoison.delete UrlHelper.user_url(Map.merge(TestConfig.database_properties(), TestConfig.test_admin()), "jan")
          <> "?rev=#{body_map["_rev"]}"
      {:error, body} ->
        {:error, body}
    end
  end

  def delete_test_admin do
    case Admin.admin_info(Map.merge(TestConfig.database_properties(), TestConfig.test_admin())) do
      {:ok, _} ->
        HTTPoison.delete(UrlHelper.admin_url(TestConfig.database_properties(), "anna", "secret"))
      {:error, body} ->
        {:error, body}
    end
  end

  def ensure_test_admin do
    TestSupport.retry_on_error(fn() ->
      Admin.create_admin(TestConfig.database_properties(), TestConfig.test_admin())
    end)
  end

  def ensure_test_security do
    TestSupport.retry_on_error(fn() ->
      Admin.set_security(Map.merge(TestConfig.database_properties(), TestConfig.test_admin()), ["anna"], ["jan"])
    end)
  end

  def secure_database do
    ensure_test_admin()
    ensure_test_user()
    ensure_test_security()
  end
end
