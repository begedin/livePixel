defmodule Snake.MixProject do
  use Mix.Project

  def project do
    [
      app: :snake,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Snake.Application, []},
      extra_applications: [:logger, :wx, :runtime_tools, :tools, :xmerl, :debugger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # audio for gl version
      {:easing, "~> 0.3.1"},
      {:pixel, path: "../pixel"},
      {:burrito, "~> 1.0"}
    ]
  end

  def releases do
    [
      snake: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            # macos: [os: :darwin, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64]
            # windows: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end
end
