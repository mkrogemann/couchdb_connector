defmodule Couchdb.Connector.Supervisor do
  use Supervisor
  @moduledoc """
  The main supervisor of the couchdb_connector application
  """

  @spec start_link(String.t) :: {:ok, pid()}
  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  @spec start(term, map()) :: {:ok, pid()}
  def start(_type, args) do
    start_link(args[:name])
  end

  @spec init(:ok) :: {:ok, {:supervisor.sup_flags, [Supervisor.Spec.spec]}}
  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end
