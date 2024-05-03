defmodule PoloWeb.ClientLive.Response do
  @moduledoc """
  LiveComponent with additional logic to handle the response block of the client.
  """
  use PoloWeb, :live_component

  @default_tab "response_preview"

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_tab()}
  end

  def assign_tab(%{assigns: %{tab: tab}} = socket) do
    assign(socket, :tab, tab)
  end

  def assign_tab(socket, tab \\ @default_tab) do
    assign(socket, :tab, tab)
  end

  def handle_event("change", %{"tab" => tab}, socket) do
    {:noreply, assign_tab(socket, tab)}
  end
end
