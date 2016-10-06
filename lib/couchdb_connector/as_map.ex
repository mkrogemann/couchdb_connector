defprotocol Couchdb.Connector.AsMap do
  @moduledoc """
  This protocol provides 'as_map' transformations that take either tuples of
  status code and content (BitString is expected) as returned by the lower
  level Couchdb Connector modules (Couchdb.Connector.Reader and
  Couchdb.Connector.Writer).
  In case there is a sensible payload (other than errors), the protocol will
  return the payload converted into a Map.
  """
  @dialyzer {:nowarn_function, __protocol__: 1}
  def as_map(json)
end

# TODO: document purpose
defimpl Couchdb.Connector.AsMap, for: Tuple do
  # @spec as_map(tuple) :: map | tuple
  def as_map(tuple) do
    case tuple do
      {:ok, document} -> {:ok, Couchdb.Connector.AsMap.as_map(document)}
      {:error, any} -> {:error, any}
    end
  end
end

# TODO: document purpose
defimpl Couchdb.Connector.AsMap, for: BitString do
  # @spec as_map(BitString) :: map
  def as_map(json) do
    case Poison.decode(json) do
      {:ok, decoded} -> decoded
      {:error, :invalid} ->
        raise RuntimeError, message:
        """
        Document returned by CouchDB is invalid
        json: #{json}
        """
      {:error, {:invalid, token}} ->
        raise RuntimeError, message:
        """
        Document returned by CouchDB is invalid
        token: #{token}
        json: #{json}
        """
    end
  end
end

# The headers returned by CouchDB are contained
# in a List of Tuples of Strings
defimpl Couchdb.Connector.AsMap, for: List do
  def as_map(tuples) do
    Enum.into(%{}, tuples)
  end
end
