defmodule Polo.Client.Parameter do
  @moduledoc """
  Representation of query parameters within the application.

  See `Polo.Client.Request` to understand how it's used.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t()
        }

  @primary_key false
  embedded_schema do
    field :name, :string
    field :value, :string, redact: true
  end

  @spec changeset(__MODULE__.t(), %{optional(any) => any}) :: Ecto.Changeset.t()
  def changeset(%Polo.Client.Parameter{} = parameter, attrs) do
    cast(parameter, attrs, [:name, :value])
  end
end
