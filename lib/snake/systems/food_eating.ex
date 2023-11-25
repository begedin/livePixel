defmodule Snake.Systems.FoodEating do
  alias Snake.Game

  def run(state) do
    case Game.get_all_components(state, :eaten) do
      [{entity, true}] -> respawn_food(state, entity)
      _ -> state
    end
  end

  defp respawn_food(state, entity) do
    x = Enum.random(0..39)
    y = Enum.random(0..39)

    state
    |> Game.set_component(entity, :position_x, x)
    |> Game.set_component(entity, :visual_x, x * 1.0)
    |> Game.set_component(entity, :position_y, y)
    |> Game.set_component(entity, :visual_y, y * 1.0)
    |> Game.remove_component(entity, :eaten)
  end
end
