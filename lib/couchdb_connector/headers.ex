defmodule Couchdb.Connector.Headers do
  @moduledoc """
  Provides commonly required http headers.

  ## Examples

      iex> Couchdb.Connector.Headers.json_header
      {"Content-Type", "application/json; charset=utf-8"}
      iex> Couchdb.Connector.Headers.www_form_header
      {"Content-Type", "application/x-www-form-urlencoded"}
  """

  def json_header do
    {"Content-Type", "application/json; charset=utf-8"}
  end

  def www_form_header do
    {"Content-Type", "application/x-www-form-urlencoded"}
  end
end
