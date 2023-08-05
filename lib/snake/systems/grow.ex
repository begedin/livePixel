defmodule Snake.Systems.Grow do
  @behaviour ECSx.System

  alias Snake.Components.Color
  alias Snake.Components.Direction
  alias Snake.Components.Food
  alias Snake.Components.PositionX
  alias Snake.Components.PositionY
  alias Snake.Components.Primitive
  alias Snake.Components.Rank
  alias Snake.Components.BodyPart

  @impl ECSx.System
  def run do
    if Food.get_all() == [] do
      spawn_food()
    end
  end

  defp spawn_food() do
    entity = Snake.Utils.new_id()
    PositionX.add(entity, Enum.random(0..39))
    PositionY.add(entity, Enum.random(0..39))
    Color.add(entity, 0xC34288)
    Primitive.add(entity, "rectangle")
    Food.add(entity)
  end
end
