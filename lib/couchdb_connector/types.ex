defmodule Couchdb.Connector.Types do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      @type db_properties :: %{protocol: String.t, hostname: String.t,
                               database: String.t, port: non_neg_integer}
      @type user_roles_list :: [String.t]
    end
  end
end
