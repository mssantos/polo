defmodule PoloWeb.ClientLive.Request do
  @moduledoc """
  LiveComponent with additional logic to handle the request block of the client.
  """
  use PoloWeb, :live_component

  alias Polo.Client

  @default_tab "request_parameters"

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_tab()
      |> clear_form()
    }
  end

  def assign_tab(%{assigns: %{tab: tab}} = socket) do
    assign(socket, :tab, tab)
  end

  def assign_tab(socket, tab \\ @default_tab) do
    assign(socket, :tab, tab)
  end

  # @doc """
  # We don't need to assign anything if form already exists.
  # """
  def clear_form(%{assigns: %{form: _form}} = socket), do: socket

  def clear_form(%{assigns: %{request: request}} = socket) do
    changeset = Client.change_request(request)

    assign_form(socket, changeset)
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event(
        "change",
        %{"request" => request_params, "tab" => tab},
        %{assigns: %{request: request}} = socket
      ) do
    request_params = merge_params(socket, request_params)

    changeset =
      request
      |> Client.change_request(request_params)
      |> Client.reset_request_embed(:body)

    socket =
      socket
      |> assign_tab(tab)
      |> assign_form(changeset)

    {:noreply, socket}
  end

  def handle_event(
        "submit",
        %{"request" => request_params},
        %{assigns: %{request: request}} = socket
      ) do
    request_params = merge_params(socket, request_params)

    case Client.create_request(request, request_params) do
      {:ok, request} ->
        send(self(), {:request_submitted, request})

        # save last valid state of form
        changeset = Client.change_request(request, request_params)

        {:noreply, assign_form(socket, changeset)}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp merge_params(socket, overrides) do
    %{}
    |> Map.merge(socket.assigns.form.params)
    |> Map.merge(overrides)
  end
end
