defmodule Couchdb.Connector.View do
  @moduledoc false

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  def fetch_all db_props, design, view do
    db_props
    |> UrlHelper.view_url(design, view)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  def create_view db_props, design, code do
    db_props
    |> UrlHelper.design_url(design)
    |> HTTPoison.put!(code)
    |> Handler.handle_put
  end

  def document_by_key db_props, design, view, key, stale \\ :update_after do
    db_props
    |> UrlHelper.view_url(design, view)
    |> UrlHelper.query_path(key, stale)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

end
