defmodule Couchdb.Connector.Configuration do
  @moduledoc """
  Provides functions to access the server's configuration.
  """

  require Logger

  use Couchdb.Connector.Types

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Reads the connector configuration as well as the server configuration at
  startup and stores the combined configuration as a Map in a linked Agent.
  """
  @spec start_link() :: {:ok, pid()}
  def start_link do
    connector_config = Enum.into(Application.get_all_env(:couchdb_connector), %{})
    case server_config(connector_config,
                       connector_config.adminname,
                       connector_config.adminpwd) do
      {:ok, server_cfg_json} ->
        start_link(%{connector: connector_config,
                     server: Poison.decode!(server_cfg_json)})
      {:error, _} ->
        _ = Logger.info("Admin credentials failed: No access to server configuration")
        # as long as we offer basic auth only, we can live without the server
        # config, so let's continue for now
        start_link(%{connector: connector_config})
    end
  end

  defp start_link config do
    {:ok, pid} = Agent.start_link(fn -> config end)
    case Process.whereis(:couchdb_config) do
      active_pid when is_pid active_pid ->
        Process.unregister(:couchdb_config)
        Agent.stop(active_pid)
        Process.register(pid, :couchdb_config)
      nil ->
        Process.register(pid, :couchdb_config)
    end
    {:ok, pid}
  end

  @doc """
  Fetches and returns the couchdb server configuration.
  """
  @spec server_config(db_properties, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def server_config db_props, admin_name, password do
    db_props
    |> UrlHelper.config_url(admin_name, password)
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @doc """
  Returns the configuration map that is maintained in the linked Agent.
  """
  @spec get() :: map()
  def get do
    :couchdb_config
    |> Process.whereis
    |> Agent.get(fn config -> config end)
  end
end
