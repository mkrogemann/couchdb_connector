defmodule Couchdb.Connector.Headers do
  @moduledoc """
  Provides commonly required http headers.

  ## Examples

      iex> Couchdb.Connector.Headers.json_header
      {"Content-Type", "application/json; charset=utf-8"}

  """

  def json_header do
    {"Content-Type", "application/json; charset=utf-8"}
  end

  def empty, do: []
end
