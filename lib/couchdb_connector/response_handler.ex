defmodule Couchdb.Connector.ResponseHandler do
  @moduledoc false

  def handle_get(%{status_code: 200, body: body}),    do: {:ok,    body}
  def handle_get(%{status_code: ___, body: body}),    do: {:error, body}

  def handle_delete(%{status_code: 200, body: body}), do: {:ok,    body}
  def handle_delete(%{status_code: ___, body: body}), do: {:error, body}

  # Matching on a status_code of 200 for a PUT is a bit unexpected, but
  # CouchDB insitis on returning 200 for a successful PUT when it comes
  # to creating admins.
  def handle_put(%{status_code: 200, body: body}),    do: {:ok,    body}
  def handle_put(%{status_code: 201, body: body}),    do: {:ok,    body}
  def handle_put(%{status_code: ___, body: body}),    do: {:error, body}

  def handle_put(%{status_code: 200, body: body, headers: headers}, :include_headers),
                                                      do: {:ok,    body, headers}
  def handle_put(%{status_code: 201, body: body, headers: headers}, :include_headers),
                                                      do: {:ok,    body, headers}
  def handle_put(%{status_code: ___, body: body, headers: headers}, :include_headers),
                                                      do: {:error, body, headers}
end
