defmodule Polo.Client.HTTP do
  alias Polo.Client.Request

  @callback send_request(request :: %Request{}) ::
              {:ok, response :: map()} | {:error, message :: term}

  def load_client do
    Application.get_env(:polo, :http_client)
  end
end
