defmodule Polo.Client.HTTP.Sandbox do
  @moduledoc """
  Implementation of `Polo.Client.HTTP` for tests.
  """
  @behaviour Polo.Client.HTTP

  @impl Polo.Client.HTTP
  def send_request(%Polo.Client.Request{method: "get", url: "/api"} = _request) do
    {:ok,
     %{
       status: 200,
       body: get_sample_body()
     }}
  end

  def send_request(%Polo.Client.Request{method: nil, url: nil} = _request) do
    {:error, "Internal Server Error"}
  end

  defp get_sample_body() do
    %{content: %{test: "sandbox"}} |> Jason.encode!(pretty: true)
  end
end
