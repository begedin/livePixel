defmodule Mix.Tasks.Snake do
  use Mix.Task

  @shortdoc "Starts snake in GL mode"

  def run(_args) do
    Application.put_env(:live_pixel, :game, :snake)

    if iex_running?() do
      Mix.Tasks.Run.run([])
    else
      Mix.Tasks.Run.run(["--no-halt"])
    end
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end
