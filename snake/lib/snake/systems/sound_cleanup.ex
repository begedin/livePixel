defmodule Snake.Systems.SoundCleanup do
  alias Snake.Game

  def run(state) do
    [{head_id, _}] = Game.get_all_components(state, :head)
    Game.remove_component(state, head_id, :sound)
  end
end
