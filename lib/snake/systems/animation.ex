defmodule Snake.Systems.Animation do
  alias Snake.Game

  def run(state) do
    with [{_, "playing"}] <- Game.get_all_components(state, :game_state),
         [{head, true}] <- Game.get_all_components(state, :head),
         [{_head, time_of_last_move}] <- Game.get_all_components(state, :time_of_last_move),
         [{_head, time_per_move}] <- Game.get_all_components(state, :time_per_move) do
      animate(state, head, time_of_last_move, time_per_move)
    else
      _ -> state
    end
  end

  defp animate(state, head_id, time_of_last_move, time_per_move) do
    head_x = Game.get_component(state, :position_x, head_id)
    head_y = Game.get_component(state, :position_y, head_id)

    direction = Game.get_component(state, :direction, head_id)

    {next_x, next_y} = Snake.Utils.next_position(head_x, head_y, direction)

    now = System.system_time(:millisecond)
    time_since_move = min(now - time_of_last_move, time_per_move)

    body_ids =
      state
      |> Game.get_all_components(:ranked_body_part)
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.map(&elem(&1, 0))

    # animate the body - every body part is interpolated to the position of the one in front
    # for the head, we pass in next_x and next_y as initial arguments
    body_ids
    |> Enum.reduce({state, {next_x, next_y}}, fn part, {state, {prev_x, prev_y}} ->
      part_x = Game.get_component(state, :position_x, part)
      part_y = Game.get_component(state, :position_y, part)

      visual_x = interpolate(part_x, prev_x, time_since_move, time_per_move)
      visual_y = interpolate(part_y, prev_y, time_since_move, time_per_move)

      state =
        state
        |> Game.set_component(part, :visual_x, visual_x)
        |> Game.set_component(part, :visual_y, visual_y)

      {state, {part_x, part_y}}
    end)
    |> elem(0)
  end

  defp interpolate(current, next, time_since_move, time_per_move) do
    progress = time_since_move * 1.0 / time_per_move
    eased_progress = Easing.cubic_in_out(progress)
    distance = next - current
    current + min(distance * eased_progress, 1.0)
  end
end
