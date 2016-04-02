defmodule Couchdb.Connector.TestSupport do

  defmacro __using__(_opts) do
    quote do

      def header_value headers, key do
        Enum.into(headers, %{})[key]
      end

      def retry(num_attempts, test_fn, match_fn, test_arg \\ nil) do
        case num_attempts do
          0 -> false
          _ ->
            response = test_fn.(test_arg)
            case match_fn.(response) do
              true -> true
              _ -> retry(num_attempts - 1, test_fn, match_fn, test_arg)
            end
        end
      end      
    end
  end
end
