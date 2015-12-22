defmodule Couchdb.Connector.Reader do
  @moduledoc false

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  def get db_props, id do
    db_props
    |> UrlHelper.document_url(id)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  def fetch_uuid db_props do
    db_props
    |> UrlHelper.fetch_uuid_url
    |> HTTPoison.get!
    |> Handler.handle_get
  end
end
