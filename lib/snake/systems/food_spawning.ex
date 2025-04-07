defmodule Snake.Systems.FoodSpawning do
  alias Snake.Game

  def run(state) do
    case Game.get_all_components(state, :food) do
      [_] -> state
      [] -> spawn_food(state)
    end
  end

  defp spawn_food(state) do
    entity = Snake.Utils.new_id()
    x = Enum.random(0..39)
    y = Enum.random(0..39)

    state
    |> Game.set_component(entity, :color, %{r: 195, g: 66, b: 136})
    |> Game.set_component(entity, :primitive, "rectangle")
    |> Game.set_component(entity, :food, true)
    |> Game.set_component(entity, :position_x, x)
    |> Game.set_component(entity, :visual_x, x * 1.0)
    |> Game.set_component(entity, :position_y, y)
    |> Game.set_component(entity, :visual_y, y * 1.0)
  end
end
