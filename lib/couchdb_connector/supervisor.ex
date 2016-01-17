defmodule Couchdb.Connector.Supervisor do
  use Supervisor
  @moduledoc """
  The main supervisor of the couchdb_connector application
  """

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def start(_type, args) do
    start_link(args[:name])
  end

  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end
