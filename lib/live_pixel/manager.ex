defmodule LivePixel.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  def setup do
    # Seed persistent components only for the first server start
    # (This will not be run on subsequent app restarts)
    :ok
  end

  def startup do
    # Load ephemeral components during first server start and again
    # on every subsequent app restart
    :ok
  end

  # Declare all valid Component types
  def components do
    [
      # MyApp.Components.SampleComponent
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      # MyApp.Systems.SampleSystem
    ]
  end
end
