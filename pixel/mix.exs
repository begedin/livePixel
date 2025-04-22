defmodule Pixel.MixProject do
  use Mix.Project

  def project do
    [
      app: :pixel,
      version: "0.2.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :wx, :runtime_tools, :tools, :xmerl, :debugger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:membrane_core, "~> 1.1"},
      {:membrane_file_plugin, "~> 0.17.2"},
      {:membrane_portaudio_plugin, "~> 0.19.2"},
      {:membrane_ffmpeg_swresample_plugin, "~> 0.20.2"},
      {:membrane_mp3_mad_plugin, "~> 0.18.3"},
      {:membrane_funnel_plugin, "~> 0.9.0"}
    ]
  end
end
