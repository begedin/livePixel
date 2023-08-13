defmodule Snake.Systems.Move do
  @behaviour ECSx.System

  alias Snake.Components.BodyPart
  alias Snake.Components.Color
  alias Snake.Components.Direction
  alias Snake.Components.Eaten
  alias Snake.Components.Food
  alias Snake.Components.Head
  alias Snake.Components.PositionX
  alias Snake.Components.PositionY
  alias Snake.Components.Primitive
  alias Snake.Components.Rank

  @impl ECSx.System
  def run do
    case Head.get_all() do
      [head] ->
        move(head)

      _ ->
        :ok
    end

    :ok
  end

  defp move(head) do
    # where the head goes depends on the direction it's facing
    head_x = PositionX.get_one(head)
    head_y = PositionY.get_one(head)
    direction = Direction.get_one(head)
    {new_x, new_y} = Snake.Utils.next_position(head_x, head_y, direction)

    # move the head
    PositionX.update(head, new_x)
    PositionY.update(head, new_y)

    # all body parts except the head, sorted by position from head to tail
    body = BodyPart.get_all() |> List.delete(head) |> Enum.sort_by(&Rank.get_one/1)

    # get the old tail
    tail_end = if body == [], do: head, else: Enum.at(body, -1)

    # move the body - every body part is moved to the position of the previous one
    Enum.reduce(body, {head_x, head_y}, fn part, {prev_x, prev_y} ->
      x = PositionX.get_one(part)
      y = PositionY.get_one(part)
      PositionX.update(part, prev_x)
      PositionY.update(part, prev_y)
      {x, y}
    end)

    # if the head has touched food, grow the snake by putting a new part at
    # the old tail position
    if food_on?(new_x, new_y) do
      end_x = PositionX.get_one(tail_end)
      end_y = PositionY.get_one(tail_end)
      grow(end_x, end_y, Enum.count(body) + 1)
      eat()
    end
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
      [id] -> Eaten.add(id)
      _ -> nil
    end
  end
end
