defmodule Snake.Systems.Move do
  @behaviour ECSx.System

  alias LSP.Types.Position
  alias Snake.Components.BodyPart
  alias Snake.Components.Color
  alias Snake.Components.Food
  alias Snake.Components.Rank
  alias Snake.Components.PositionX
  alias Snake.Components.PositionY
  alias Snake.Components.Primitive
  alias Snake.Components.Direction

  @impl ECSx.System
  def run do
    BodyPart.get_all()
    |> Enum.map(&{&1, Rank.get_one(&1)})
    |> Enum.sort_by(&elem(&1, 1))
    |> IO.inspect()

    BodyPart.get_all() |> Enum.sort_by(&Rank.get_one/1) |> move()
  end

  defp move([]), do: :ok

  defp move([head | body] = snake) do
    head_x = PositionX.get_one(head)
    head_y = PositionY.get_one(head)

    direction = Direction.get_one(head)
    {new_x, new_y} = Snake.Utils.next_position(head_x, head_y, direction)

    PositionX.update(head, new_x)
    PositionY.update(head, new_y)

    [tail_end | _] = Enum.reverse(snake)
    end_x = PositionX.get_one(tail_end)
    end_y = PositionY.get_one(tail_end)

    if food_on?(head_x, head_y) do
      grow(end_x, end_y, Enum.count(snake))
      eat()
    end

    Enum.reduce(body, {head_x, head_y}, fn part, {prev_x, prev_y} ->
      x = PositionX.get_one(part)
      y = PositionY.get_one(part)
      PositionX.update(part, prev_x)
      PositionY.update(part, prev_y)
      {x, y}
    end)
  end

  defp food_on?(x, y) do
    with [id] <- Food.get_all(),
         food_x when food_x == x <- PositionX.get_one(id),
         food_y when food_y == y <- PositionY.get_one(id) do
      true
    else
      _ -> false
    end
  end

  defp grow(x, y, rank) do
    entity = Snake.Utils.new_id()
    PositionX.add(entity, x)
    PositionY.add(entity, y)
    Rank.add(entity, rank)
    Primitive.add(entity, "rectangle")
    Color.add(entity, 0xDE3249)
    BodyPart.add(entity)
  end

  defp eat() do
    case Food.get_all() do
      [id] ->
        PositionX.update(id, Enum.random(0..39))
        PositionY.update(id, Enum.random(0..39))

      _ ->
        nil
    end
  end
end
