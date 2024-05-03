defmodule Polo.Client.Body do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    content: binary()
  }

  @primary_key false
  embedded_schema do
    field :content, :binary
  end

  @spec changeset(__MODULE__.t, %{optional(any) => any}) :: Ecto.Changeset.t()
  def changeset(%Polo.Client.Body{} = body, attrs \\ %{}) do
    body
    |> cast(attrs, [:content])
    |> validate_json_string()
  end

  @spec validate_json_string(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp validate_json_string(changeset) do
    validate_change(changeset, :content, fn :content, content ->
      case Jason.decode(content) do
        {:ok, _} ->
          []

        {:error, _} ->
          [
            content:
              {"content body can't be decoded to JSON", additional: "#{content} can't be decoded"}
          ]
      end
    end)
  end
end
