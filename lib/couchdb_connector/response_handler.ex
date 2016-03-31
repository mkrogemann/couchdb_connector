defmodule Couchdb.Connector.ResponseHandler do
  @moduledoc false

  def handle_get(%{status_code: 200, body: body}),    do: {:ok,    body}
  def handle_get(%{status_code: ___, body: body}),    do: {:error, body}

  def handle_delete(%{status_code: 200, body: body}), do: {:ok,    body}
  def handle_delete(%{status_code: ___, body: body}), do: {:error, body}

  def handle_put(%{status_code: 201, body: body}),    do: {:ok,    body}
  def handle_put(%{status_code: ___, body: body}),    do: {:error, body}

  def handle_put(%{status_code: 201, body: body, headers: headers},
                 _include_headers = true),            do: {:ok,    body, headers}
  def handle_put(%{status_code: ___, body: body, headers: headers},
                 _include_headers = true),            do: {:error, body, headers}
end
