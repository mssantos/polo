defmodule Polo.Client.Header do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :value, :string, redact: true
  end

  def changeset(%Polo.Client.Header{} = header, attrs) do
    cast(header, attrs, [:name, :value])
  end
end
