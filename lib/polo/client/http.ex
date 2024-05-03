defmodule Polo.Client.HTTP do
  alias Polo.Client.Request

  @callback send_request(request :: Request.t()) ::
              {:ok, response :: map()} | {:error, message :: atom() | String.t()}

  def load_client do
    Application.get_env(:polo, :http_client)
  end
end
