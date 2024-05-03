defmodule Polo.Client.Response do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    body: binary(),
    status: integer(),
    received_at: NaiveDateTime.t(),
    headers: list(Polo.Client.Header.t())
  }

  embedded_schema do
    field :body, :binary
    field :status, :integer
    field :received_at, :naive_datetime

    embeds_many :headers, Polo.Client.Header
  end

  @spec changeset(__MODULE__.t, %{optional(any) => any}) :: Ecto.Changeset.t()
  def changeset(response, attrs \\ %{}) do
    response
    |> cast(attrs, [:body, :status])
    |> validate_required([:body, :status])
    |> cast_embed(:headers)
    |> put_change(:received_at, NaiveDateTime.utc_now())
  end
end
