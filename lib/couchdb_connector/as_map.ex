defprotocol AsMap do
  @moduledoc """
  """
  def as_map(json)
end

defimpl AsMap, for: BitString do

  Poison.decode("")
  def as_map(json) do
    case Poison.decode(json) do
      {:ok, decoded} -> decoded
      {:error, :invalid} ->
        raise RuntimeError, message:
        """
        Document returned by CouchDB is invalid
        json: #{json}
        """
      {:error, reason} ->
        raise RuntimeError, message: "Document returned by CouchDB is not parseable\nreason: #{elem(reason, 0)}\nchar: #{elem(reason, 1)}\njson: #{json}"
    end
  end
end
