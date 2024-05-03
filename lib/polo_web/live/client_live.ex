defmodule PoloWeb.ClientLive do
  @moduledoc """
  LiveView to handle interactions when sending requests.
  """
  alias Phoenix.LiveView.AsyncResult
  use PoloWeb, :live_view

  alias Polo.Client

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_client_request_component_id()
     |> assign_client_response_component_id()
     |> assign_request()
     |> assign_request_methods()
     |> clear_response()}
  end

  def assign_client_request_component_id(socket) do
    assign(socket, :client_request_component_id, "client-request-component")
  end

  def assign_client_response_component_id(socket) do
    assign(socket, :client_response_component_id, "client-response-component")
  end

  def assign_request(socket, request \\ Client.new_request()) do
    assign(socket, :request, request)
  end

  def assign_request_methods(socket) do
    assign(socket, :request_methods, Client.request_methods())
  end

  def clear_response(socket) do
    assign_response(socket, %AsyncResult{})
  end

  def assign_response(socket, response) do
    assign(socket, :response, response)
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, cancel_async(socket, :send_request)}
  end

  def handle_event("not_implemented", _params, socket) do
    {:noreply, put_flash(socket, :error, "This action is not implemented yet.")}
  end

  def handle_info({:request_submitted, request}, socket) do
    socket =
      socket
      |> assign_request(request)
      |> assign_response(AsyncResult.loading())
      |> start_async(:request, fn ->
        Client.send_request(request)
      end)

    {:noreply, socket}
  end

  def handle_async(:request, {:ok, {:ok, response}}, socket) do
    socket = assign_response(socket, AsyncResult.ok(response))

    {:noreply, socket}
  end

  def handle_async(:request, {:ok, {:error, _changeset}}, socket) do
    socket =
      socket
      |> clear_response()
      |> put_flash(:error, "Your request has failed.")

    {:noreply, socket}
  end

  def handle_async(:request, {:exit, _}, socket) do
    socket =
      socket
      |> clear_response()
      |> put_flash(:error, "Your request has failed.")

    {:noreply, socket}
  end
end
