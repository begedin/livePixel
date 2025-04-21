defmodule Snake.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [Snake.GLGame]
    opts = [strategy: :one_for_one, name: Snake.Supervisor, auto_shutdown: :any_significant]
    Supervisor.start_link(children, opts)
  end
end
