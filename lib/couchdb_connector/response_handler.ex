defmodule Couchdb.Connector.ResponseHandler do
  @moduledoc """
  Response handler provides functions that handle responses for the happy
  paths and error cases.
  """

  @spec handle_get(%{atom => Integer, atom => String.t}) :: {:ok, String.t} | {:error, String.t}
  def handle_get(%{status_code: 200, body: body}),    do: {:ok,    body}
  def handle_get(%{status_code: ___, body: body}),    do: {:error, body}

  @spec handle_delete(%{atom => Integer, atom => String.t}) :: {:ok, String.t} | {:error, String.t}
  def handle_delete(%{status_code: 200, body: body}), do: {:ok,    body}
  def handle_delete(%{status_code: ___, body: body}), do: {:error, body}

  # Matching on a status_code of 200 for a PUT is a bit unexpected, but
  # CouchDB insists on returning 200 for a successful PUT when it comes
  # to creating admins.
  @spec handle_put(%{atom => Integer, atom => String.t}) :: {:ok, String.t} | {:error, String.t}
  def handle_put(%{status_code: 200, body: body}),    do: {:ok,    body}
  def handle_put(%{status_code: 201, body: body}),    do: {:ok,    body}
  def handle_put(%{status_code: ___, body: body}),    do: {:error, body}

  @spec handle_put(%{atom => Integer, atom => String.t, atom => String.t}, atom)
    :: {:ok, String.t, String.t} | {:error, String.t, String.t}
  def handle_put(%{status_code: 200, body: body, headers: headers}, :include_headers),
                                                      do: {:ok,    body, headers}
  def handle_put(%{status_code: 201, body: body, headers: headers}, :include_headers),
                                                      do: {:ok,    body, headers}
  def handle_put(%{status_code: ___, body: body, headers: headers}, :include_headers),
                                                      do: {:error, body, headers}
end
