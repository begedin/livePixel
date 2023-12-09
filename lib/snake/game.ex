defmodule Snake.Game do
  @components [
    :color,
    :direction,
    :eaten,
    :food,
    :game_state,
    :head,
    :next_direction,
    :position_x,
    :position_y,
    :primitive,
    :ranked_body_part,
    :time_of_last_move,
    :time_per_move,
    :visual_x,
    :visual_y,
    :sound
  ]

  def spawn_player(%{} = state) do
    id =
      case get_all_components(state, :head) do
        [] -> Snake.Utils.new_id()
        [{head, true}] -> head
      end

    state
    |> set_component(id, :position_x, 20)
    |> set_component(id, :visual_x, 20.0)
    |> set_component(id, :position_y, 20)
    |> set_component(id, :visual_y, 20.0)
    |> set_component(id, :primitive, "rectangle")
    |> set_component(id, :ranked_body_part, 0)
    |> set_component(id, :time_of_last_move, System.system_time(:millisecond))
    |> set_component(id, :time_per_move, 200)
    |> set_component(id, :game_state, "playing")
    |> set_component(id, :direction, "none")
    |> set_component(id, :next_direction, "none")
    |> set_component(id, :head, true)
    |> set_component(id, :color, 0xDE7749)
  end

  def spawn_food(%{} = state) do
    id =
      case get_all_components(state, :food) do
        [] -> Snake.Utils.new_id()
        [{food, true}] -> food
      end

    x = Enum.random(0..39)
    y = Enum.random(0..39)

    state
    |> set_component(id, :position_x, x)
    |> set_component(id, :visual_x, x * 1.0)
    |> set_component(id, :position_y, y)
    |> set_component(id, :visual_y, y * 1.0)
    |> set_component(id, :primitive, "rectangle")
    |> set_component(id, :food, true)
    |> set_component(id, :color, 0xC34288)
  end

  def paused?(%{} = state) do
    case get_all_components(state, :game_state) do
      [{_, "pause"}] -> true
      _ -> false
    end
  end

  def game_over?(%{} = state) do
    case get_all_components(state, :game_state) do
      [{_, "game_over"}] -> true
      _ -> false
    end
  end

  def playing?(%{} = state) do
    case get_all_components(state, :game_state) do
      [{_, "playing"}] -> true
      _ -> false
    end
  end

  def set_component(%{} = state, entity, type, data)
      when is_binary(entity) and type in @components do
    Map.update(state, type, %{entity => data}, &Map.put(&1, entity, data))
  end

  @spec get_all_components(map(), atom()) :: list({map, any})
  def get_all_components(%{} = state, type) when type in @components do
    state |> Map.get(type, %{}) |> Map.to_list()
  end

  def get_component(%{} = state, type, entity) when type in @components and is_binary(entity) do
    state |> Map.fetch!(type) |> Map.fetch!(entity)
  end

  def remove_component(%{} = state, entity, type)
      when type in @components and is_binary(entity) do
    Map.update(state, type, %{}, &Map.delete(&1, entity))
  end

  def render(%{} = state) do
    sound =
      case get_all_components(state, :sound) do
        [] -> nil
        [{_head_id, sound}] -> sound
      end

    %{
      world: render_world(state),
      sound: sound
    }
  end

  defp render_world(state) do
    x_map = state |> get_all_components(:visual_x) |> Enum.sort()
    y_map = state |> get_all_components(:visual_y) |> Enum.sort()
    shape_map = state |> get_all_components(:primitive) |> Enum.sort()
    color_map = state |> get_all_components(:color) |> Enum.sort()

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

    case get_food(state) do
      nil -> snake
      food -> [food | snake]
    end
  end

  defp get_food(state) do
    case get_all_components(state, :food) do
      [] ->
        nil

      [{food_id, true}] ->
        food_x = get_component(state, :position_x, food_id)
        food_y = get_component(state, :position_y, food_id)
        food_shape = get_component(state, :primitive, food_id)
        %{"id" => food_id, "x" => food_x, "y" => food_y, "shape" => food_shape}
    end
  end

  def config do
    %{
      width: 800,
      height: 800,
      background: "#000000"
    }
  end

  def assets do
    %{
      sounds: %{
        eat: "/sounds/eat.wav",
        move: "/sounds/move.wav"
      }
    }
  end
end
