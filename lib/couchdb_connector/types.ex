defmodule Couchdb.Connector.Types do
  @moduledoc """
  The types module contains only type definitions that other modules can
  make use of by simply using this modules: 'use Couchdb.Connector.Types'
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      @type db_properties :: %{protocol: String.t, hostname: String.t,
                               database: String.t, port: non_neg_integer}
      @type user_roles :: [String.t]
      @type headers :: [{String.t, String.t}] # List of header names and values
      @type basic_auth :: %{user: String.t, password: String.t}
      @type view_key :: %{design: String.t, view: String.t, key: String.t}
    end
  end
end
