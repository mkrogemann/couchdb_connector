defmodule Couchdb.Connector.TestConfig do

  def database_properties do
    %{
      protocol: Application.get_env(:couchdb_connector, :protocol),
      hostname: Application.get_env(:couchdb_connector, :hostname),
      database: Application.get_env(:couchdb_connector, :database),
      port: Application.get_env(:couchdb_connector, :port)
    }
  end

  def database_url do
    "#{database_server_url()}/#{database_properties()[:database]}"
  end

  def database_server_url do
    "#{database_properties()[:protocol]}://#{database_properties()[:hostname]}:#{database_properties()[:port]}"
  end

  def db_exists do
    url = "#{database_server_url()}/#{database_properties()[:database]}"
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        true
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        false
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise RuntimeError, message: "Error: #{inspect reason}"
    end
  end

  def test_user do
    %{user: "jan", password: "relax"}
  end

  def test_admin do
    %{user: "anna", password: "secret"}
  end

  def test_view_key do
    test_view_key("test_name")
  end

  def test_view_key(key) do
    %{design: "test_view", view: "test_fetch", key: key}
  end
end
