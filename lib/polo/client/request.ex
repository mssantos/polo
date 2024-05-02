defmodule Polo.Client.Request do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_methods [:get, :post, :put, :patch, :delete, :options, :head]

  embedded_schema do
    field :method, Ecto.Enum, values: @valid_methods
    field :url, :string
    field :sent_at, :naive_datetime

    embeds_many :headers, Polo.Client.Header, on_replace: :delete
    embeds_many :parameters, Polo.Client.Parameter, on_replace: :delete
    embeds_one :body, Polo.Client.Body, on_replace: :delete
  end

  def changeset(request, attrs \\ %{}) do
    request
    |> cast(attrs, [:method, :url])
    |> validate_required([:method, :url])
    |> validate_inclusion(:method, @valid_methods, message: "must be a valid HTTP method")
    |> cast_headers()
    |> cast_parameters()
    |> cast_body()
    |> maybe_add_default_header()
    |> maybe_add_default_parameter()
  end

  def methods, do: Ecto.Enum.values(__MODULE__, :method)

  @doc """
  Ensure reset of embed fields errors after their first validation.

  If we don't reset them, their error messages appear after the first submit only. Additional attempts to submit a 
  request with invalid params don't work, and no feedback is displayed.
  """
  def reset_embed(changeset, embed) do
    update_change(changeset, embed, fn change ->
      %{change | action: nil, errors: []}
    end)
  end

  defp cast_headers(changeset) do
    cast_embed(changeset, :headers, sort_param: :headers_sort, drop_param: :headers_drop)
  end

  defp cast_parameters(changeset) do
    cast_embed(changeset, :parameters, sort_param: :parameters_sort, drop_param: :parameters_drop)
  end

  defp cast_body(changeset) do
    cast_embed(changeset, :body)
  end

  defp maybe_add_default_header(changeset) do
    case Ecto.Changeset.get_change(changeset, :headers) do
      nil ->
        Ecto.Changeset.put_embed(changeset, :headers, [%Polo.Client.Header{}])

      _ ->
        changeset
    end
  end

  defp maybe_add_default_parameter(changeset) do
    case Ecto.Changeset.get_change(changeset, :parameters) do
      nil ->
        Ecto.Changeset.put_embed(changeset, :parameters, [%Polo.Client.Parameter{}])

      _ ->
        changeset
    end
  end
end
