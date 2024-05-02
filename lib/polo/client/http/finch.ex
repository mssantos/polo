defmodule Polo.Client.HTTP.Finch do
  @behaviour Polo.Client.HTTP

  require Logger

  @impl Polo.Client.HTTP
  def send_request(request_data) do
    case prepare_and_send(request_data) do
      {:ok, %Finch.Response{} = response} ->
        response =
          response
          |> Map.from_struct()
          |> process_response()

        {:ok, process_response_body(response)}

      {:error, %Mint.TransportError{} = error} ->
        {:error, Exception.message(error)}

      {:error, reason} ->
        Logger.error(inspect(reason))
        {:error, "Unknown error. Check the app logs."}
    end
  end

  defp prepare_and_send(request_data) do
    %{method: method, url_with_parameters: url, headers: headers, body: body} =
      prepare(request_data)

    Finch.build(
      method,
      url,
      headers,
      body
    )
    |> Finch.request(Polo.Finch)
  end

  defp prepare(request_data) do
    %{}
    |> Map.merge(%{headers: prepare_headers(request_data.headers)})
    |> Map.merge(%{url: prepare_url(request_data.url)})
    |> Map.merge(%{parameters: prepare_parameters(request_data.parameters)})
    |> Map.merge(%{body: prepare_body(request_data.body)})
    |> Map.merge(%{method: request_data.method})
    |> prepare_url_with_parameters()
    |> Map.drop([:url, :parameters])
  end

  defp prepare_headers([]), do: []

  defp prepare_headers(headers) do
    headers
    |> Enum.filter(fn header -> header.name != nil or header.value != nil end)
    |> Enum.map(fn header -> {header.name, header.value} end)
  end

  defp prepare_url(url), do: URI.parse(url)

  defp prepare_parameters([]), do: nil

  defp prepare_parameters(parameters) do
    parameters
    |> Enum.filter(fn parameter -> parameter.name != nil or parameter.value != nil end)
    |> Enum.map(fn parameter -> {parameter.name, parameter.value} end)
    |> URI.encode_query()
  end

  defp prepare_body(nil), do: ""

  defp prepare_body(body), do: body.content

  defp prepare_url_with_parameters(%{url: url, parameters: parameters} = request_data) do
    Map.put(request_data, :url_with_parameters, %URI{url | query: parameters} |> URI.to_string())
  end

  defp process_response(response_data) do
    response_data
    |> process_response_body()
    |> process_response_headers()
  end

  defp process_response_body(%{body: body} = response) do
    case Jason.decode(body) do
      {:ok, result} ->
        {:ok, pretty_json} = Jason.encode(result, pretty: true)
        %{response | body: pretty_json}

      {:error, _} ->
        response
    end
  end

  defp process_response_headers(%{headers: headers} = response) do
    %{
      response
      | headers:
          Enum.map(headers, fn {header_name, header_value} ->
            %{name: header_name, value: header_value}
          end)
    }
  end
end
