defmodule Couchdb.Connector.Configuration do
  @moduledoc """
  TODO
  """

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  def get db_props, admin_name, password do
    db_props
    |> UrlHelper.config_url(admin_name, password)
    |> HTTPoison.get!
    |> Handler.handle_get
  end
end
