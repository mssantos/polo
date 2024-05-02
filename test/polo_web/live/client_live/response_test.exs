defmodule PoloWeb.ClientLive.ResponseTest do
  use PoloWeb.ConnCase

  defp create_socket(_) do
    %{socket: %Phoenix.LiveView.Socket{}}
  end

  defp assert_socket_assigns(socket, key, value) do
    assert socket.assigns[key] == value
    socket
  end

  setup :create_socket

  # TODO
end
