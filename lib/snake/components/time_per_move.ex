defmodule Snake.Components.TimePerMove do
  @moduledoc """
  Holds how much time it takes for the snake to move.

  The bigger the snake is, the faster it will eventually move, so this component
  manages that "velocity".
  """
  use ECSx.Component, value: :integer, unique: true
end
