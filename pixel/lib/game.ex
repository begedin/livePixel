defmodule Pixel.Game do
  @moduledoc """
  Behaviour for a Pixel game.

  Defines the callbacks a module that uses the `Pixel.Loop` module must implement.
  """

  @doc """
  The init callback receives the options passed into Pixel.Loop and should return the
  full state of the game, including logic state, loaded assets, etc.

  This state is what will be modified and passed along in subsequent render and update calls.
  """
  @callback init(opts :: map()) :: any()

  @doc """
  Runs at a specified render_interval, receives the current game state and
  should be in charge of ensuring the game state is rendered to the screen.

  Can also modify state if needed.
  """
  @callback render(state :: any()) :: any()

  @doc """
  Runs at as fast a rate as possible, receives the current game state and the list of keys pressed.
  Is intended to update the game logic based on input/or and time passed.

  Should return the updated game state.
  """
  @callback update(state :: any(), keys :: list(integer())) :: any()

  @doc """
  Runs when the game is terminated (it crashes, or the window is closed).

  Can be used to clean up any resources used by the game.

  Should probably call `System.halt(0)` at the end.
  """
  @callback terminate(reason :: any(), state :: any()) :: any()
end
