defmodule Couchdb.Connector.Options do
  @moduledoc false

  def default, do: [hackney: [pool: :couchdb_pool]]
end
