defmodule Snake.Systems.Movement do
  alias Snake.Game

  def run(state) do
    with [{_, "playing"}] <- Game.get_all_components(state, :game_state),
         [{head, true}] <- Game.get_all_components(state, :head),
         [{_head, time_of_last_move}] <- Game.get_all_components(state, :time_of_last_move),
         [{_head, time_per_move}] <- Game.get_all_components(state, :time_per_move),
         true <- System.system_time(:millisecond) - time_of_last_move >= time_per_move do
      state
      |> move(head)
      |> Game.set_component(head, :time_of_last_move, System.system_time(:millisecond))
    else
      _ -> state
    end
  end

  defp move(state, head) do
    # we need old info for the tail to understand where to grow a new body part
    # if we move onto a food entity
    {tail_id, tail_rank} =
      state
      |> Game.get_all_components(:ranked_body_part)
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.at(-1)

    tail_x = Game.get_component(state, :position_x, tail_id)
    tail_y = Game.get_component(state, :position_y, tail_id)

    # move the head
    state
    |> Game.set_component(head, :sound, "move")
    |> move_body(head)
    |> eat_and_grow(head, tail_rank, tail_x, tail_y)
    |> change_direction(head)
  end

  defp move_body(state, head) do
    # these will the determine where the head will go next
    head_x = Game.get_component(state, :position_x, head)
    head_y = Game.get_component(state, :position_y, head)
    direction = Game.get_component(state, :direction, head)
    {new_x, new_y} = Snake.Utils.next_position(head_x, head_y, direction)

    state
    |> Game.get_all_components(:ranked_body_part)
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce({state, {new_x, new_y}}, fn part, {state, {prev_x, prev_y}} ->
      x = Game.get_component(state, :position_x, part)
      y = Game.get_component(state, :position_y, part)

      state =
        state
        |> Game.set_component(part, :position_x, prev_x)
        |> Game.set_component(part, :position_y, prev_y)

      {state, {x, y}}
    end)
    |> elem(0)
  end

  defp eat_and_grow(state, head, tail_rank, tail_x, tail_y) do
    # if the head has touched food, grow the snake by putting a new part at
    # the old tail position
    if food_on?(state, head) do
      time_per_move = max(Game.get_component(state, :time_per_move, head) - 50, 100)

      state
      |> grow(tail_rank, tail_x, tail_y)
      |> Game.set_component(head, :time_per_move, time_per_move)
      |> Game.set_component(head, :sound, "eat")
      |> eat()
    else
      state
    end
  end

  defp food_on?(state, head) do
    x = Game.get_component(state, :position_x, head)
    y = Game.get_component(state, :position_y, head)

    with [{id, true}] <- Game.get_all_components(state, :food),
         food_x when food_x == x <- Game.get_component(state, :position_x, id),
         food_y when food_y == y <- Game.get_component(state, :position_y, id) do
      true
    else
      _ -> false
    end
  end

  defp grow(state, tail_rank, x, y) do
    entity = Snake.Utils.new_id()

    state
    |> Game.set_component(entity, :position_x, x)
    |> Game.set_component(entity, :position_y, y)
    |> Game.set_component(entity, :visual_x, x * 1.0)
    |> Game.set_component(entity, :visual_y, y * 1.0)
    |> Game.set_component(entity, :primitive, "rectangle")
    |> Game.set_component(entity, :color, 0xDE3249)
    |> Game.set_component(entity, :ranked_body_part, tail_rank + 1)
  end

  defp eat(state) do
    case Game.get_all_components(state, :food) do
      [{id, _true}] -> Game.set_component(state, id, :eaten, true)
      _ -> nil
    end
  end

  defp change_direction(state, head) do
    next_direction = Game.get_component(state, :next_direction, head)
    Game.set_component(state, head, :direction, next_direction)
  end
end
