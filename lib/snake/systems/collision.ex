defmodule Snake.Systems.Collision do
  alias Snake.Game

  require Logger

  def run(state) do
    if collision?(state) do
      game_over(state)
    else
      state
    end
  end

  defp collision?(state) do
    body_part_ids =
      state
      |> Game.get_all_components(:ranked_body_part)
      |> Enum.map(&elem(&1, 0))

    Enum.any?(body_part_ids, fn part ->
      x = Game.get_component(state, :position_x, part)
      y = Game.get_component(state, :position_y, part)

      x < 0 or x > 39 or y < 0 or y > 39 or
        Enum.any?(body_part_ids, fn other ->
          other_x = Game.get_component(state, :position_x, other)
          other_y = Game.get_component(state, :position_y, other)
          other != part and other_x == x and other_y == y
        end)
    end)
  end

  defp game_over(state) do
    [{head, true}] = Game.get_all_components(state, :head)
    Game.set_component(state, head, :game_state, "game_over")
  end
end
