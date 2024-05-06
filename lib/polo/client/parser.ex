defmodule Polo.Client.Parser do
  @moduledoc """
  Custom parser for NimblePublisher. It parses data from markdown into a valid elixir struct,
  and updates the struct with the content of the markdown.
  """

  @doc false
  def parse(_path, contents) do
    [attrs, body] = :binary.split(contents, ["\n---\n"])

    # Need to keep the same converter on body.
    # Ref.: https://github.com/dashbitco/nimble_publisher/blob/master/lib/nimble_publisher.ex#L127
    body = Earmark.as_html!(body, %Earmark.Options{})

    attrs =
      attrs
      |> Jason.decode!()
      |> merge_params(%{"documentation" => body})

    {attrs, body}
  end

  defp merge_params(attrs, overrides) do
    %{}
    |> Map.merge(attrs)
    |> Map.merge(%{"id" => generate_request_id(attrs)})
    |> Map.merge(overrides)
  end

  defp generate_request_id(attrs) do
    :crypto.hash(:md5, :erlang.term_to_binary(attrs))
    |> Base.encode64()
    |> String.replace("/", "-")
  end
end
