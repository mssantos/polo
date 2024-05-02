defmodule Polo.Client.Parameter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :value, :string, redact: true
  end

  def changeset(%Polo.Client.Parameter{} = parameter, attrs) do
    cast(parameter, attrs, [:name, :value])
  end
end
