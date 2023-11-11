defmodule Snake.Components.VisualY do
  @moduledoc """
  Holds the visual position of the snake's body part on the y axis.

  The visual position is used for rendering only and is interpolated from the
  logical position and the next logical position.
  """
  use ECSx.Component, value: :float, unique: true
end
