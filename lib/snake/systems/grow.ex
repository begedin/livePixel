defmodule Snake.Systems.Grow do
  @behaviour ECSx.System

  alias Snake.Components.Color
  alias Snake.Components.Eaten
  alias Snake.Components.Food
  alias Snake.Components.PositionX
  alias Snake.Components.PositionY
  alias Snake.Components.Primitive
  alias Snake.Components.VisualX
  alias Snake.Components.VisualY

  @impl ECSx.System
  def run do
    if Food.get_all() == [] do
      spawn_food()
    end

    case Eaten.get_all() do
      [id] ->
        Eaten.remove(id)
        PositionX.update(id, Enum.random(0..39))
        PositionY.update(id, Enum.random(0..39))

      _ ->
        :ok
    end

    :ok
  end

  defp spawn_food() do
    entity = Snake.Utils.new_id()
    Color.add(entity, 0xC34288)
    Primitive.add(entity, "rectangle")
    Food.add(entity)

    x = Enum.random(0..39)
    PositionX.add(entity, x)
    VisualX.add(entity, x * 1.0)

    y = Enum.random(0..39)
    PositionY.add(entity, y)
    VisualY.add(entity, y * 1.0)
  end
end
