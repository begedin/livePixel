defmodule Snake.Systems.Input do
  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    ECSx.ClientEvents.get_and_clear() |> Enum.each(&process_event/1)
  end

  alias Snake.Components.Direction

  defp process_event({entity, :spawn}) do
    Snake.Components.PositionX.add(entity, 20)
    Snake.Components.PositionY.add(entity, 20)
    Snake.Components.Rank.add(entity, 0)
    Snake.Components.Direction.add(entity, "none")
    Snake.Components.Primitive.add(entity, "rectangle")
    Snake.Components.Color.add(entity, 0xDE7749)
    Snake.Components.Head.add(entity)
    Snake.Components.BodyPart.add(entity)
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
    if Direction.exists?(entity) do
      Direction.update(entity, direction)
    else
      Direction.add(entity, direction)
    end
  end
end
