defmodule Couchdb.Connector.Storage do
  @moduledoc false

  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  def storage_up db_props do
    db_props
    |> UrlHelper.database_url
    |> HTTPoison.put!("{}", [ Headers.json_header ])
    |> Handler.handle_put
  end

  def storage_down db_props do
    db_props
    |> UrlHelper.database_url
    |> HTTPoison.delete!
    |> Handler.handle_delete
  end

end
