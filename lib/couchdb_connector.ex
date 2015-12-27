defmodule Couchdb.Connector do
  @moduledoc false

  def start_link(_repo, _options) do
    {:ok, self}
  end
end
