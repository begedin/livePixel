defmodule Snake.Manager do
  use ECSx.Manager

  def setup do
    :ok
  end

  defp clear(component) do
    Enum.map(component.get_all, &component.remove/1)
  end

  def startup do
    Enum.map(components(), &clear/1)
    :ok
  end

  def components do
    [
      Snake.Components.BodyPart,
      Snake.Components.Color,
      Snake.Components.Direction,
      Snake.Components.Eaten,
      Snake.Components.Food,
      Snake.Components.Head,
      Snake.Components.PositionX,
      Snake.Components.PositionY,
      Snake.Components.Primitive,
      Snake.Components.Rank,
      Snake.Components.TimeOfLastMove,
      Snake.Components.TimePerMove,
      Snake.Components.VisualX,
      Snake.Components.VisualY
    ]
  end

  def systems do
    [
      Snake.Systems.Move,
      Snake.Systems.Animation,
      Snake.Systems.Grow,
      Snake.Systems.Input
    ]
  end

  def get_world do
    x_map = Snake.Components.VisualX.get_all() |> Enum.sort()
    y_map = Snake.Components.VisualY.get_all() |> Enum.sort()
    shape_map = Snake.Components.Primitive.get_all() |> Enum.sort()
    color_map = Snake.Components.Color.get_all() |> Enum.sort()

    snake =
      [x_map, y_map, shape_map, color_map]
      |> Enum.zip()
      |> Enum.map(fn {{id, x}, {id, y}, {id, shape}, {id, color}} ->
        %{
          "id" => id,
          "x" => x,
          "y" => y,
          "shape" => shape,
          "width" => 20,
          "height" => 20,
          "color" => color
        }
      end)

    case get_food() do
      nil -> snake
      food -> [food | snake]
    end
  end

  defp get_food() do
    case Snake.Components.Food.get_all() do
      [] ->
        nil

      [food_id] ->
        food_x = Snake.Components.PositionX.get_one(food_id)
        food_y = Snake.Components.PositionY.get_one(food_id)
        food_shape = Snake.Components.Primitive.get_one(food_id)
        %{"id" => food_id, "x" => food_x, "y" => food_y, "shape" => food_shape}
    end
  end
end
