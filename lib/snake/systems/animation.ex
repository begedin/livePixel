defmodule Snake.Systems.Animation do
  @behaviour ECSx.System

  alias Snake.Components.BodyPart
  alias Snake.Components.Direction
  alias Snake.Components.Head
  alias Snake.Components.PositionX
  alias Snake.Components.PositionY
  alias Snake.Components.Rank
  alias Snake.Components.TimeOfLastMove
  alias Snake.Components.TimePerMove
  alias Snake.Components.VisualX
  alias Snake.Components.VisualY

  @impl ECSx.System
  def run do
    case [Head.get_all(), TimeOfLastMove.get_all(), TimePerMove.get_all()] do
      [[head], [{head, time_of_last_move}], [{head, time_per_move}]] ->
        animate(head, time_of_last_move, time_per_move)

      _ ->
        :ok
    end

    :ok
  end

  defp animate(head_id, time_of_last_move, time_per_move) do
    head_x = PositionX.get_one(head_id)
    head_y = PositionY.get_one(head_id)

    direction = Direction.get_one(head_id)

    {next_x, next_y} = Snake.Utils.next_position(head_x, head_y, direction)

    now = System.system_time(:millisecond)
    time_since_move = now - time_of_last_move

    update_visual_position(
      head_id,
      interpolate(head_x, next_x, time_since_move, time_per_move),
      interpolate(head_y, next_y, time_since_move, time_per_move)
    )

    # all body parts except the head, sorted by position from head to tail
    body = BodyPart.get_all() |> List.delete(head_id) |> Enum.sort_by(&Rank.get_one/1)

    # move the body - every body part is moved to the position of the previous one
    Enum.reduce(body, {head_x, head_y}, fn part, {prev_x, prev_y} ->
      part_x = PositionX.get_one(part)
      part_y = PositionY.get_one(part)

      update_visual_position(
        part,
        interpolate(part_x, prev_x, time_since_move, time_per_move),
        interpolate(part_y, prev_y, time_since_move, time_per_move)
      )

      {part_x, part_y}
    end)
  end

  defp update_visual_position(id, visual_x, visual_y) do
    VisualX.update(id, visual_x)
    VisualY.update(id, visual_y)
  end

  defp interpolate(current, next, time_since_move, time_per_move) do
    progress = time_since_move * 1.0 / time_per_move
    eased_progress = Easing.cubic_in_out(progress)
    distance = next - current
    current + distance * eased_progress
  end
end
