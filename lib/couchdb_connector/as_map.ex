defprotocol Couchdb.Connector.AsMap do
  @moduledoc """
  This protocol provides the as_map function that translates a BitString
  returned from CouchDB into a Map.
  """
  def as_map(json)
end

defimpl Couchdb.Connector.AsMap, for: BitString do
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
