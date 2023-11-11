defmodule Snake.Components.TimeOfLastMove do
  @moduledoc """
  Holds the moment the snake has last moved.
  Snake moves in discrete time units, which are bigger than the engine tick rate,
  so we need to keep track of when it last moved, to understand when it will move next.
  """
  use ECSx.Component, value: :integer, unique: true
end
