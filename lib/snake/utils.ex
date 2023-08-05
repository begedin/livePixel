defmodule Snake.Utils do
  def new_id do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64()
    |> binary_part(0, 32)
  end

  def next_position(x, y, "none"), do: {x, y}
  def next_position(x, y, "left"), do: {x - 1, y}
  def next_position(x, y, "right"), do: {x + 1, y}
  def next_position(x, y, "up"), do: {x, y - 1}
  def next_position(x, y, "down"), do: {x, y + 1}
end
