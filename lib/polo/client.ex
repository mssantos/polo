defmodule Polo.Client do
  alias Polo.Client.{HTTP, Request, Response}

  def new_request, do: struct(Request)

  def new_response, do: struct(Response)

  def change_request(%Request{} = request, attrs \\ %{}) do
    Request.changeset(request, attrs)
  end

  def create_request(%Request{} = request, attrs) do
    request
    |> change_request(attrs)
    |> Ecto.Changeset.apply_action(:create)
  end

  def send_request(%Request{} = request) do
    case HTTP.load_client().send_request(request) do
      {:ok, response_data} ->
        new_response() |> create_response(response_data)

      {:error, reason} ->
        new_response() |> create_response(%{status: 500, body: reason})
    end
  end

  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

  def create_response(%Response{} = response, attrs) do
    response
    |> change_response(attrs)
    |> Ecto.Changeset.apply_action(:create)
  end

  defdelegate request_methods, to: Request, as: :methods
  defdelegate reset_request_embed(changeset, embed), to: Request, as: :reset_embed
end
