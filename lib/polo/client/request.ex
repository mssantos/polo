defmodule Polo.Client.Request do
  @moduledoc """
  Representation of a request within the app.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          method: atom(),
          url: String.t(),
          sent_at: NaiveDateTime.t(),
          headers: list(Polo.Client.Header.t()),
          parameters: list(Polo.Client.Parameter.t()),
          body: Polo.Client.Body.t(),
          documentation: binary(),
          collection_name: String.t(),
          title: String.t()
        }

  @valid_methods [:get, :post, :put, :patch, :delete, :options, :head]

  @primary_key {:id, :binary, autogenerate: false}
  embedded_schema do
    field :method, Ecto.Enum, values: @valid_methods
    field :url, :string
    field :sent_at, :naive_datetime
    field :documentation, :binary
    field :collection_name, :string
    field :title, :string

    embeds_many :headers, Polo.Client.Header, on_replace: :delete
    embeds_many :parameters, Polo.Client.Parameter, on_replace: :delete
    embeds_one :body, Polo.Client.Body, on_replace: :delete
  end

  @doc """
  Build request from data provided in collections dir. This function is required by NimblePublisher.
  """
  @spec build(String.t(), %{required(any) => any()}, any()) :: __MODULE__.t()
  def build(filename, request_params, _) do
    [collection_name, request_title] =
      filename |> Path.rootname() |> Path.split() |> Enum.take(-2)

    attrs =
      %{}
      |> Map.merge(request_params)
      |> Map.merge(%{"collection_name" => collection_name})
      |> Map.merge(%{"title" => request_title})

    struct(__MODULE__)
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action!(:create)
  end

  @spec changeset(__MODULE__.t(), %{optional(any) => any}) :: Ecto.Changeset.t()
  def changeset(request, attrs \\ %{}) do
    request
    |> cast(attrs, [:method, :url, :documentation, :id, :collection_name, :title])
    |> validate_required([:method, :url])
    |> validate_inclusion(:method, @valid_methods, message: "must be a valid HTTP method")
    |> validate_length(:title, max: 20)
    |> cast_headers()
    |> cast_parameters()
    |> cast_body()
    |> maybe_add_default_header(request)
    |> maybe_add_default_parameter(request)
  end

  @spec methods() :: list(atom())
  def methods, do: Ecto.Enum.values(__MODULE__, :method)

  @doc """
  Ensure reset of embed fields errors after their first validation.

  If we don't reset them, their error messages appear after the first submit only. Additional attempts to submit a 
  request with invalid params don't work, and no feedback is displayed.
  """
  @spec reset_embed(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def reset_embed(changeset, embed) do
    update_change(changeset, embed, fn change ->
      %{change | action: nil, errors: []}
    end)
  end

  @spec cast_headers(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp cast_headers(changeset) do
    cast_embed(changeset, :headers, sort_param: :headers_sort, drop_param: :headers_drop)
  end

  @spec cast_parameters(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp cast_parameters(changeset) do
    cast_embed(changeset, :parameters, sort_param: :parameters_sort, drop_param: :parameters_drop)
  end

  @spec cast_body(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp cast_body(changeset) do
    cast_embed(changeset, :body)
  end

  @spec maybe_add_default_header(Ecto.Changeset.t(), __MODULE__.t()) :: Ecto.Changeset.t()
  defp maybe_add_default_header(changeset, request) when request.headers == [] do
    case Ecto.Changeset.get_change(changeset, :headers) do
      nil ->
        Ecto.Changeset.put_embed(changeset, :headers, [%Polo.Client.Header{}])

      _ ->
        changeset
    end
  end

  defp maybe_add_default_header(changeset, _request), do: changeset

  @spec maybe_add_default_parameter(Ecto.Changeset.t(), __MODULE__.t()) :: Ecto.Changeset.t()
  defp maybe_add_default_parameter(changeset, request) when request.parameters == [] do
    case Ecto.Changeset.get_change(changeset, :parameters) do
      nil ->
        Ecto.Changeset.put_embed(changeset, :parameters, [%Polo.Client.Parameter{}])

      _ ->
        changeset
    end
  end

  defp maybe_add_default_parameter(changeset, _request), do: changeset
end
