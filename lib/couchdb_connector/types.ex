defmodule Couchdb.Connector.Types do
  @moduledoc """
  The types module contains only type definitions that other modules can
  make use of by simply using this modules: 'use Couchdb.Connector.Types'
  """

  @typedoc """
  Database properties: host, port, protocol (http|https), database name
  """
  @type db_properties :: %{protocol: String.t, hostname: String.t,
                           database: String.t, port: non_neg_integer,
                           user: String.t, password: String.t}

  @typedoc "CouchDB user role is just a string, user_roles a list of strings."
  @type user_roles :: [String.t]

  @typedoc "HTTP headers are modeled as a list of name-value tuples"
  @type headers :: [{String.t, String.t}]

  @typedoc "Username and password for basic authentication"
  @type basic_auth :: %{user: String.t, password: String.t}

  @typedoc "User information"
  @type user_info :: %{user: String.t, password: String.t}

  @typedoc """
  Design name, view name and lookup key are often used together in view
  queries so it makes sense to wrap them in a type.
  """
  @type view_key :: %{design: String.t, view: String.t, key: any}
end
