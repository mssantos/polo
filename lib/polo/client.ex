defmodule Polo.Client do
  @moduledoc """
  The client in Polo manages all aspects of requests and responses.

  Its two primary structures, Polo.Client.Request and Polo.Client.Response,
  represent a request and a response within the application.

  Another important component handled by this module is Polo.Client.HTTP,
  which defines the necessary functions for a HTTP client to be used within the app.
  This is because Polo is designed to be agnostic about how requests are going to be
  sent. While the default is Finch, the Elixir ecosystem offers several
  alternatives such as Req or HTTPoison. Having a module that outlines the
  requirements for a client implementation ensures compatibility across different
  choices.
  """

  alias Polo.Client.{HTTP, Parser, Request, Response}

  use NimblePublisher,
    build: Request,
    from: Application.app_dir(:polo, "priv/collections/**/*.md"),
    as: :requests,
    parser: Parser

  @doc false
  def all_requests(), do: @requests

  @doc """
  Get requests from id.
  """
  @spec get_request(String.t()) :: Request.t() | nil
  def get_request(request_id) do
    Enum.find(all_requests(), &(&1.id == request_id))
  end

  @doc """
  Group requests by collection.
  """
  @spec requests_by_collection() :: %{required(String.t()) => list(Request.t())}
  def requests_by_collection do
    Enum.group_by(all_requests(), fn request -> request.collection_name end)
  end

  @doc """
  Prevent direct access to internal structures from outside the context.
  """
  @spec new_request() :: Request.t()
  def new_request, do: struct(Request)

  @doc """
  Prevent direct access to internal structures from outside the context.
  """
  @spec new_response() :: Response.t()
  def new_response, do: struct(Response)

  @spec change_request(Request.t(), %{optional(any) => any}) :: Ecto.Changeset.t()
  def change_request(%Request{} = request, attrs \\ %{}) do
    Request.changeset(request, attrs)
  end

  @doc """
  Since the application doesn't store requests, we use `Ecto.Changeset.apply_action/2` to create
  a request struct or to returno an invalid changeset.
  """
  @spec create_request(Request.t(), %{optional(any) => any}) ::
          {:ok, Request.t()} | {:error, Ecto.Changeset.t()}
  def create_request(%Request{} = request, attrs \\ %{}) do
    request
    |> change_request(attrs)
    |> Ecto.Changeset.apply_action(:create)
  end

  @doc """
  Calls the HTTP client in use and sends the request.

  See `Polo.Client.HTTP.load_client/0` for more information.
  """
  @spec send_request(Request.t()) :: {:ok, Response.t()} | {:error, Ecto.Changeset.t()}
  def send_request(%Request{} = request) do
    case HTTP.load_client().send_request(request) do
      {:ok, response_data} ->
        new_response() |> create_response(response_data)

      {:error, reason} ->
        new_response() |> create_response(%{status: 500, body: reason})
    end
  end

  @spec change_response(Response.t(), %{optional(any) => any}) :: Ecto.Changeset.t()
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

  @doc """
  Since the application doesn't store responses, we use `Ecto.Changeset.apply_action/2` to create
  a request struct or to returno an invalid changeset.
  """
  @spec create_response(Response.t(), %{optional(any) => any}) ::
          {:ok, Response.t()} | {:error, Ecto.Changeset.t()}
  def create_response(%Response{} = response, attrs) do
    response
    |> change_response(attrs)
    |> Ecto.Changeset.apply_action(:create)
  end

  @doc """
  Delegates the call to list the available HTTP methods to `Polo.Client.Request.methods/0`.
  """
  @spec request_methods() :: list(atom())
  defdelegate request_methods, to: Request, as: :methods

  @doc """
  Delegates the call to reset an embed changeset to `Polo.Client.Response.reset_embed/2`.
  """
  @spec reset_request_embed(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  defdelegate reset_request_embed(changeset, embed), to: Request, as: :reset_embed
end
