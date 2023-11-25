defmodule Snake.Controller do
  alias Snake.Game

  @arrow_keys ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown"]

  @direction %{
    "ArrowLeft" => "left",
    "ArrowRight" => "right",
    "ArrowUp" => "up",
    "ArrowDown" => "down"
  }

  def run(%{} = state, {:keydown, k}) when k in @arrow_keys do
    case Game.get_all_components(state, :game_state) do
      [{player_id, "playing"}] -> set_direction(state, player_id, @direction[k])
      _ -> state
    end
  end

  def run(%{} = state, {:keydown, " "}) do
    case Game.get_all_components(state, :game_state) do
      [{player_id, "playing"}] -> Game.set_component(state, player_id, :game_state, "pause")
      [{player_id, "pause"}] -> Game.set_component(state, player_id, :game_state, "playing")
    end
  end

  def run(%{} = state, _params) do
    state
  end

  defp set_direction(%{} = state, entity, direction) do
    state
    |> then(fn state ->
      if Game.get_all_components(state, :direction) == [{entity, "none"}] do
        Game.set_component(state, entity, :direction, direction)
      else
        state
      end
    end)
    |> Game.set_component(entity, :next_direction, direction)
  end
end
