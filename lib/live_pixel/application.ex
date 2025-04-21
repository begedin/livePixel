defmodule LivePixel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    case Application.get_env(:live_pixel, :game) do
      :snake -> start_snake()
      _ -> start_phx()
    end
  end

  defp start_snake() do
    IO.puts("Starting snake")

    children = [
      Snake.GLGame
    ]

    opts = [strategy: :one_for_one, name: LivePixel.Supervisor, auto_shutdown: :any_significant]
    Supervisor.start_link(children, opts)
  end

  defp start_phx() do
    children = [
      # Start the Telemetry supervisor
      LivePixelWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LivePixel.PubSub},
      # Start the Endpoint (http/https)
      LivePixelWeb.Endpoint
      # Start a worker by calling: LivePixel.Worker.start_link(arg)
      # {LivePixel.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LivePixel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivePixelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
