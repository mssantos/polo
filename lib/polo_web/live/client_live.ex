defmodule PoloWeb.ClientLive do
  @moduledoc """
  LiveView to handle interactions when sending requests.
  """
  alias Phoenix.LiveView.AsyncResult
  use PoloWeb, :live_view

  alias Polo.Client

  def mount(%{"request_id" => request_id}, _uri, socket) do
    case Client.get_request(request_id) do
      nil ->
        socket =
          socket
          |> assign_initial_data()
          |> put_flash(:error, "Request not found.")

        {:ok, socket}

      request ->
        socket = assign_initial_data(socket, request)

        {:ok, socket}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, assign_initial_data(socket)}
  end

  defp assign_initial_data(socket, request \\ Client.new_request()) do
    socket
    |> assign_client_request_component_id()
    |> assign_client_response_component_id()
    |> assign_collections()
    |> assign_request(request)
    |> assign_request_methods()
    |> assign_collection_selected()
    |> assign_request_selected(request.id)
    |> assign_curl(nil)
    |> clear_response()
  end

  def assign_client_request_component_id(socket) do
    assign(socket, :client_request_component_id, "client-request-component")
  end

  def assign_client_response_component_id(socket) do
    assign(socket, :client_response_component_id, "client-response-component")
  end

  def assign_collection_selected(%{assigns: %{request: request}} = socket) do
    assign(socket, :collection_selected, request.collection_name)
  end

  def assign_collection_selected(socket) do
    assign(socket, :collection_selected, nil)
  end

  def assign_request_selected(socket, request_selected \\ nil) do
    assign(socket, :request_selected, request_selected)
  end

  def assign_collections(socket) do
    assign(socket, :collections, Client.requests_by_collection())
  end

  def assign_request(socket, request) do
    assign(socket, :request, request)
  end

  def assign_request_methods(socket) do
    assign(socket, :request_methods, Client.request_methods())
  end

  def clear_response(socket) do
    assign_response(socket, AsyncResult.ok(nil))
  end

  def assign_response(socket, response) do
    assign(socket, :response, response)
  end

  def assign_curl(socket, curl) do
    assign(socket, :curl, curl)
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, cancel_async(socket, :send_request)}
  end

  def handle_event("to_curl", _params, socket) do
    result = Client.to_curl(socket.assigns.request)

    {:noreply, assign_curl(socket, result)}
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
    socket =
      socket
      |> assign_response(AsyncResult.ok(socket.assigns.response, response))
      |> assign_curl(Client.to_curl(socket.assigns.request))

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
