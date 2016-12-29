defmodule Couchdb.Connector.TestSupport.Macros do

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
              _ ->
                :timer.sleep(5) # TODO: convert this into a parameter
                retry(num_attempts - 1, test_fn, match_fn, test_arg)
            end
        end
      end

      def retry_on_error(fun, num_attempts \\ 3) do
        Couchdb.Connector.TestSupport.retry_on_error(fun, num_attempts)
      end

      def id_from_url url do
        hd(Enum.reverse(String.split(url, "/", trim: true)))
      end
    end

  end
end


defmodule Couchdb.Connector.TestSupport do
  require Logger

  # Couchdb sometimes surprises us with errors like this one:
  # {:error, %HTTPoison.Error{id: nil, reason: :closed}}
  # These closed connections happen a lot on Travis which makes triggers
  # lots of false alerts.
  # TODO: would like to match more precisely so that we only retry in case
  # of 'closed' errors.
  def retry_on_error(fun, num_attempts \\ 5) do
    case num_attempts do
      1 -> fun.()
      _ ->
        response = fun.()
        case response do
          {:error, %HTTPoison.Error{reason: _}} ->
            Logger.warn("Couchdb HTTP connection error - #{num_attempts - 1} attempts left")
            :timer.sleep(20)
            retry_on_error(fun, num_attempts - 1)
          success ->
            success
        end
    end
  end
end
