defmodule Couchdb.Connector.Admin do
  @moduledoc """
  The Admin module provides functions to create and update users in
  the CouchDB server given by the database properties.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.Admin.create_user(db_props, "jan", "relax", ["couchdb contributor"])
      {:ok,
       "{\\"ok\\":true,\\"id\\":\\"org.couchdb.user:jan\\",\\"rev\\":\\"1-1d509578d1bc8cba3a6690fca5e7a9fd\\"}\\n",
       [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
        {"Location", "http://localhost:5984/_users/org.couchdb.user:jan"},
        {"ETag", "\\"1-1d509578d1bc8cba3a6690fca5e7a9fd\\""},
        {"Date", "Thu, 31 Mar 2016 21:50:04 GMT"},
        {"Content-Type", "text/plain; charset=utf-8"}, {"Content-Length", "83"},
        {"Cache-Control", "must-revalidate"}]}

      Couchdb.Connector.Admin.create_user(db_props, "jan", "relax", ["couchdb contributor"])
      {:error,
        "{\\"error\\":\\"conflict\\",\\"reason\\":\\"Document update conflict.\\"}\\n",
        [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
         {"Date", "Thu, 31 Mar 2016 21:50:06 GMT"},
         {"Content-Type", "text/plain; charset=utf-8"}, {"Content-Length", "58"},
         {"Cache-Control", "must-revalidate"}]}

      Couchdb.Connector.Admin.user_info(db_props, "jan")
      {:ok,
        "{\\"_id\\":\\"org.couchdb.user:jan\\",\\"_rev\\":\\"1-...\\",
          \\"password_scheme\\":\\"pbkdf2\\",\\"iterations\\":10,\\"type\\":\\"user\\",
          \\"roles\\":[\\"couchdb contributor\\"],\\"name\\":\\"jan\\",
          \\"derived_key\\":\\"a294518...\\",\\"salt\\":\\"70869...\\"}\\n"}

      Couchdb.Connector.Admin.destroy_user(db_props, "jan")
      {:ok,
        "{\\"ok\\":true,\\"id\\":\\"org.couchdb.user:jan\\",\\"rev\\":\\"2-429e8839208ed64cd58eae75957cc0d4\\"}\\n"}

      Couchdb.Connector.Admin.user_info(db_props, "jan")
      {:error, "{\\"error\\":\\"not_found\\",\\"reason\\":\\"deleted\\"}\\n"}

      Couchdb.Connector.Admin.destroy_user(db_props, "jan")
      {:error, "{\\"error\\":\\"not_found\\",\\"reason\\":\\"deleted\\"}\\n"}

  """

  alias Couchdb.Connector.Types
  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Create a new user with given username, password and roles. In case of success,
  the function will respond with {:ok, body, headers}. In case of failures (e.g.
  if user already exists), the response will be {:error, body, headers}.
  Please note that the credentials used in db_properties must be the credentials
  of an admin user.
  """
  @spec create_user(Types.db_properties, Types.user_info, Types.user_roles)
    :: {:ok, String.t, Types.headers} | {:error, String.t, Types.headers}
  def create_user(db_props, user_auth, roles) do
    db_props
    |> UrlHelper.user_url(user_auth[:user])
    |> do_create_user(user_to_json(user_auth, roles))
    |> Handler.handle_put(:include_headers)
  end

  defp do_create_user(url, json) do
    HTTPoison.put! url, json, [Headers.json_header]
  end

  defp user_to_json(user_auth, roles) do
    Poison.encode! %{"name" => user_auth[:user],
                     "password" => user_auth[:password],
                     "roles" => roles,
                     "type" => "user"}
  end

  @doc """
  Create a new admin with given username and password. In case of success,
  the function will respond with an empty body. In case of failures (e.g.
  if admin already exists), the response will be {:error, body, headers}.
  """
  @spec create_admin(Types.db_properties, Types.user_info)
    :: {:ok, String.t, Types.headers} | {:error, String.t, Types.headers}
  def create_admin(db_props, admin_info) do
    db_props
    |> UrlHelper.admin_url(admin_info[:user])
    |> do_create_admin(admin_info[:password])
    |> Handler.handle_put(:include_headers)
  end

  defp do_create_admin(url, password) do
    HTTPoison.put! url, "\"" <> password <> "\"", [Headers.www_form_header]
  end

  @doc """
  Returns the public information for the given user or an error in case the
  user does not exist.
  """
  @spec user_info(Types.db_properties, String.t)
    :: {:ok, String.t} | {:error, String.t}
  def user_info(db_props, username) do
    db_props
    |> UrlHelper.user_url(username)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Returns hashed information for the given admin or an error in case the admin
  does not exist or if the given credentials are wrong.
  """
  @spec admin_info(Types.db_properties)
    :: {:ok, String.t} | {:error, String.t}
  def admin_info db_props do
    db_props
    |> UrlHelper.admin_url(db_props[:user])
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Deletes the given user from the database server or returns an error in case
  the user cannot be found. Requires admin basic auth credentials.
  """
  @spec destroy_user(Types.db_properties, String.t)
  :: {:ok, String.t} | {:error, String.t}
  def destroy_user(db_props, username) do
    case user_info(db_props, username) do
      {:ok, user_json} ->
        user = Poison.decode! user_json
        do_destroy_user(db_props, username, user["_rev"])
      error -> error
    end
  end

  defp do_destroy_user(db_props, username, rev) do
    db_props
    |> UrlHelper.user_url(username)
    |> do_http_delete(rev)
    |> Handler.handle_delete
  end

  defp do_http_delete(url) do
    HTTPoison.delete! url
  end

  defp do_http_delete(url, rev) do
    HTTPoison.delete! url <> "?rev=#{rev}"
  end

  @doc """
  Deletes the given admin from the database server or returns an error in case
  the admin cannot be found.
  """
  @spec destroy_admin(Types.db_properties, String.t, String.t)
    :: {:ok, String.t} | {:error, String.t}
  def destroy_admin(db_props, username, password) do
    db_props
    |> UrlHelper.admin_url(username, password)
    |> do_http_delete
    |> Handler.handle_delete
  end


  @doc """
  Set the security object for a given database. Security object includes admins
  and members for the database.
  """
  # TODO: add user roles
  @spec set_security(Types.db_properties, list(String.t), list(String.t))
    :: {:ok, String.t} | {:error, String.t}
  def set_security(db_props, admins, members) do
    db_props
    |> UrlHelper.security_url
    |> do_set_security(security_to_json(admins, members))
    |> Handler.handle_put
  end

  defp do_set_security(url, json) do
    HTTPoison.put! url, json, [Headers.json_header]
  end

  defp security_to_json(admins, members) do
    Poison.encode!(
    %{:admins  => %{:names => admins,  :roles => ["admins"]},
      :members => %{:names => members, :roles => ["members"]}
    })
  end
end
