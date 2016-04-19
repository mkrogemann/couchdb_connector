defmodule Couchdb.Connector.Auth do
  @moduledoc """
  This module provides authentication macros.
  """

  alias Couchdb.Connector.Configuration
  alias Couchdb.Connector.AuthSupport

  @doc """
  This macro will figure out what authentication scheme is activated (if any)
  and delegate to the appropriate authentication support function.
  """
  defmacro with_user_auth db_props do
    quote bind_quoted: [db_props: db_props] do
      case Configuration.get[:connector][:authentication] do
        :basic_auth ->
          AuthSupport.authenticate_basic(db_props)
        _ ->
          AuthSupport.authenticate_none(db_props)
      end
    end
  end
end


defmodule Couchdb.Connector.AuthSupport do
  @moduledoc """
  This module provides support functions for authentication purposes.
  """

  @doc """
  Builds the server URL with basic authentication included.
  """
  def authenticate_basic db_props do
    "#{db_props[:protocol]}://#{db_props[:username]}:#{db_props[:password]}@#{db_props[:hostname]}:#{db_props[:port]}"
  end

  @doc """
  Builds the server URL without any authentication paramters.
  """
  def authenticate_none db_props do
    "#{db_props[:protocol]}://#{db_props[:hostname]}:#{db_props[:port]}"
  end
end
