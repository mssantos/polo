defmodule PoloWeb.ClientLive do
  @moduledoc """
  LiveView to handle interactions when sending requests.
  """
  alias Phoenix.LiveView.AsyncResult
  use PoloWeb, :live_view

  alias Polo.Client

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(
        %{"request_id" => request_id},
        _uri,
        socket
      ) do
    case Client.get_request(request_id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Request not found.")
         |> assign_client_request_component_id()
         |> assign_client_response_component_id()
         |> assign_collections()
         |> assign_request()
         |> assign_request_methods()
         |> assign_collection_selected()
         |> assign_request_selected()
         |> clear_response()}

      request ->
        {:noreply,
         socket
         |> assign_client_request_component_id()
         |> assign_client_response_component_id()
         |> assign_collections()
         |> assign_request(request)
         |> assign_request_methods()
         |> assign_collection_selected()
         |> assign_request_selected(request_id)
         |> clear_response()}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign_client_request_component_id()
     |> assign_client_response_component_id()
     |> assign_collections()
     |> assign_request()
     |> assign_request_methods()
     |> assign_collection_selected()
     |> assign_request_selected()
     |> clear_response()}
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
