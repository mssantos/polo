defmodule Polo.Client.HTTP do
  @moduledoc """
  Behaviour with the list of functions required for a new implementation
  of a HTTP client within the app. 

  To use it, add `use Polo.Client.HTTP` at the top of the implementation.

  See `Polo.Client.HTTP.Finch` for an example.
  """

  alias Polo.Client.Request

  @callback send_request(request :: Request.t()) ::
              {:ok, response :: map()} | {:error, message :: atom() | String.t()}

  @doc """
  Load the HTTP client set in config to send requests.
  """
  def load_client do
    Application.get_env(:polo, :http_client)
  end
end
