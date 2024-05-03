defmodule Polo.RequestsFixtures do
  @moduledoc """
  Helper functions for testing requests.
  """

  def valid_request_method, do: Enum.random(Polo.Client.request_methods())

  def valid_request_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      url: "https://api.example.com",
      method: valid_request_method()
    })
  end

  def request_fixture(attrs \\ %{}) do
    {:ok, request} =
      attrs
      |> valid_request_attributes()
      |> Polo.Client.change_request()
      |> Ecto.Changeset.apply_action(:request_fixture)

    request
  end
end
