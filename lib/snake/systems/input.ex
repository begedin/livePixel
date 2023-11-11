defmodule Snake.Systems.Input do
  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    ECSx.ClientEvents.get_and_clear() |> Enum.each(&process_event/1)
  end

  alias Snake.Components.BodyPart
  alias Snake.Components.Color
  alias Snake.Components.Direction
  alias Snake.Components.NextDirection
  alias Snake.Components.Head
  alias Snake.Components.PositionX
  alias Snake.Components.PositionY
  alias Snake.Components.Primitive
  alias Snake.Components.Rank
  alias Snake.Components.TimeOfLastMove
  alias Snake.Components.TimePerMove
  alias Snake.Components.VisualX
  alias Snake.Components.VisualY

  defp process_event({entity, :spawn}) do
    BodyPart.add(entity)
    Color.add(entity, 0xDE7749)
    Direction.add(entity, "none")
    NextDirection.add(entity, "none")
    Head.add(entity)

    PositionX.add(entity, 20)
    VisualX.add(entity, 20.0)

    PositionY.add(entity, 20)
    VisualY.add(entity, 20.0)

    Primitive.add(entity, "rectangle")

    Rank.add(entity, 0)

    TimeOfLastMove.add(entity, System.system_time(:millisecond))
    TimePerMove.add(entity, 500)
  end

  @arrow_keys ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown"]
  @direction %{
    "ArrowLeft" => "left",
    "ArrowRight" => "right",
    "ArrowUp" => "up",
    "ArrowDown" => "down"
  }

  defp process_event({entity, {:keydown, k}}) when k in @arrow_keys do
    set_direction(entity, @direction[k])
  end

  defp process_event(_), do: nil

  defp set_direction(entity, direction) do
    if Direction.get_one(entity) == "none" do
      Direction.update(entity, direction)
    end

    NextDirection.update(entity, direction)
  end
end
