defmodule Polo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PoloWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:polo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Polo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Polo.Finch},
      # Start a worker by calling: Polo.Worker.start_link(arg)
      # {Polo.Worker, arg},
      # Start to serve requests, typically the last entry
      PoloWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Polo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PoloWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
