defmodule Polo.Client do
  alias Polo.Client.{HTTP, Request, Response}

  @spec new_request() :: Request.t()
  def new_request, do: struct(Request)

  @spec new_response() :: Response.t()
  def new_response, do: struct(Response)

  @spec change_request(Request.t(), %{optional(any) => any) :: Ecto.Changeset.t()
  def change_request(%Request{} = request, attrs \\ %{}) do
    Request.changeset(request, attrs)
  end

  @spec create_request(Request.t(), %{optional(any) => any) :: {:ok, Request.t()} | {:error, Ecto.Changeset.t()}
  def create_request(%Request{} = request, attrs \\ %{}) do
    request
    |> change_request(attrs)
    |> Ecto.Changeset.apply_action(:create)
  end

  @spec send_request(Request.t()) :: {:ok, Response.t()} | {:error, Ecto.Changeset.t()}
  def send_request(%Request{} = request) do
    case HTTP.load_client().send_request(request) do
      {:ok, response_data} ->
        new_response() |> create_response(response_data)

      {:error, reason} ->
        new_response() |> create_response(%{status: 500, body: reason})
    end
  end

  @spec change_response(Request.t(), %{optional(any) => any) :: Ecto.Changeset.t()
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

  @spec create_response(Response.t(), %{optional(any) => any) :: {:ok, Response.t()} | {:error, Ecto.Changeset.t()}
  def create_response(%Response{} = response, attrs) do
    response
    |> change_response(attrs)
    |> Ecto.Changeset.apply_action(:create)
  end

  @spec request_methods() :: list(atom())
  defdelegate request_methods, to: Request, as: :methods

  @spec reset_request_embed(Ecto.Changeset.t, atom()) :: Ecto.Changeset.t()
  defdelegate reset_request_embed(changeset, embed), to: Request, as: :reset_embed
end
