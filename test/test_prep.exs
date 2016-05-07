defmodule Couchdb.Connector.TestPrep do

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Admin
  alias Couchdb.Connector.UrlHelper

  def ensure_database do
    {:ok, _} = HTTPoison.put "#{TestConfig.database_url}", "{}", [ Headers.json_header ]
  end

  def delete_database do
    {:ok, _} = HTTPoison.delete "#{TestConfig.database_url}"
  end

  def ensure_document(doc, id) do
    {:ok, _} = HTTPoison.put "#{TestConfig.database_url}/#{id}", doc, [ Headers.json_header ]
  end

  def ensure_view(design_name, code) do
    {:ok, _} = HTTPoison.put "#{TestConfig.database_url}/_design/#{design_name}", code, [ Headers.json_header ]
  end

  def ensure_test_user do
    Admin.create_user(
      TestConfig.database_properties, {"anna", "secret"}, {"jan", "relax"}, ["members"])
  end

  def delete_test_user do
    case Admin.user_info(TestConfig.database_properties, {"anna", "secret"}, "jan") do
      {:ok, body} ->
        {:ok, body_map} = Poison.decode body
        HTTPoison.delete UrlHelper.user_url(TestConfig.database_properties, {"anna", "secret"}, "jan")
          <> "?rev=#{body_map["_rev"]}"
      {:error, body} ->
        {:error, body}
    end
  end

  def delete_test_admin do
    case Admin.admin_info(TestConfig.database_properties, "anna", "secret") do
      {:ok, _} ->
        HTTPoison.delete(UrlHelper.admin_url(TestConfig.database_properties, "anna", "secret"))
      {:error, body} ->
        {:error, body}
    end
  end

  def ensure_test_admin do
    Admin.create_admin(TestConfig.database_properties, {"anna", "secret"})
  end

  def ensure_test_security do
    Admin.set_security(TestConfig.database_properties, {"anna", "secret"}, ["anna"], ["jan"])
  end

  def secure_database do
    ensure_test_admin
    ensure_test_user
    ensure_test_security
  end  
end
