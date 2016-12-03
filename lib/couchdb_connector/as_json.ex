defprotocol Couchdb.Connector.AsJson do
  @moduledoc """
  This protocol provides an 'as_json' transformation that takes a document as
  input (a Map representation is expected here) and transforms that into
  the format expected by the lower level Couchdb Writer module (BitString).
  """
  @dialyzer {:nowarn_function, __protocol__: 1}
  def as_json(map)
end

defimpl Couchdb.Connector.AsJson, for: Map do
  # @spec as_json(map) :: String.t
  def as_json(map) do
    Poison.encode!(map)
  end
end
