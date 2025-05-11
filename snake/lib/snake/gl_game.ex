defmodule Snake.GLGame do
  use Pixel.Loop, width: 800, height: 800, update_interval: :max, render_interval: div(1000, 60)

  require Logger

  alias Pixel.Audio.SoundEffect
  alias Pixel.Keyboard
  alias Pixel.Math.Mat4
  alias Pixel.Renderer
  alias Pixel.Renderer.Font
  alias Pixel.Renderer.Primitive
  alias Pixel.Renderer.Shader
  alias Pixel.Renderer.Sprite
  alias Pixel.Renderer.Texture2D
  alias Snake.Controller
  alias Snake.Game
  alias Snake.Utils

  defstruct [
    :sprite_shader,
    :sprite_renderer,
    :body_chunk,
    :keys,
    :font,
    :game_state
  ]

  @impl true

  def init(%{width: width, height: height}) do
    projection = Mat4.ortho_2d_top_left(width, height)

    sprite_shader =
      Shader.init(
        Utils.to_priv("shaders/sprite/vertex.vs"),
        Utils.to_priv("shaders/sprite/fragment.fs")
      )
      |> Shader.use_shader()
      |> Shader.set(~c"image", 0)
      |> Shader.set(~c"projection", [projection |> Mat4.flatten()])

    sprite_renderer = Sprite.new(sprite_shader)

    body_chunk =
      Primitive.new(
        :rectangle,
        Shader.init(
          Utils.to_priv("shaders/vertex.vs"),
          Utils.to_priv("shaders/fragment.fs")
        )
        |> Shader.use_shader()
        |> Shader.set(~c"projection", [Mat4.flatten(projection)])
      )

    font =
      Font.new(
        Shader.init(
          Utils.to_priv("shaders/font/vertex.vs"),
          Utils.to_priv("shaders/font/fragment.fs")
        )
        |> Shader.use_shader()
        |> Shader.set(~c"u_projection", [Mat4.flatten(projection)]),
        Texture2D.load(Utils.to_priv("textures/ascii_rgb.png"), false)
      )

    Logger.info("Game initialized.")

    %__MODULE__{
      game_state: Game.spawn_player(%{}),
      sprite_shader: sprite_shader,
      sprite_renderer: sprite_renderer,
      body_chunk: body_chunk,
      keys: [],
      font: font
    }
  end

  @sound_map %{
    "move" => Utils.to_priv("sounds/move.mp3"),
    "eat" => Utils.to_priv("sounds/eat.mp3"),
    "game_over" => Utils.to_priv("sounds/game_over.mp3")
  }

  @impl true
  def render(%__MODULE__{} = state) do
    %{world: world, sound: sound} = Game.render(state.game_state)
    if sound, do: @sound_map |> Map.fetch!(sound) |> SoundEffect.play()

    Renderer.clear_frame(0.5, 0.0, 1.0, 1.0)

    rectangles =
      Enum.map(world, fn rect ->
        {rect["x"] * rect["width"], rect["y"] * rect["height"], rect["width"], rect["height"]}
      end)

    Primitive.draw(state.body_chunk, rectangles)

    Font.draw(state.font, "#{Game.score(state.game_state)}", 740, 10, 1.0)

    %{state | game_state: Snake.Systems.SoundCleanup.run(state.game_state)}
  end

  @impl true
  def update(%__MODULE__{} = state, keys) do
    game_state = state.game_state |> handle_input(keys) |> run_systems()
    %{state | game_state: game_state}
  end

  @control_keys ~w(Space ArrowLeft ArrowRight ArrowUp ArrowDown)

  defp handle_input(game_state, keys) do
    case Keyboard.first_pressed(keys, @control_keys) do
      nil -> game_state
      key -> Controller.run(game_state, {:keydown, key})
    end
  end

  def run_systems(game_state) do
    if Game.playing?(game_state) do
      game_state
      |> Snake.Systems.Movement.run()
      |> Snake.Systems.Animation.run()
      |> Snake.Systems.Collision.run()
      |> Snake.Systems.FoodEating.run()
      |> Snake.Systems.FoodSpawning.run()
    else
      game_state
    end
  end

  @impl true
  @spec terminate(any(), struct) :: :ok
  def terminate(reason, _state) do
    Logger.info("Terminating game: #{reason}")
    # Schedule the system halt to happen after this function returns
    # This avoids the "has no local return" warning while still shutting down the app
    spawn(fn -> System.stop(0) end)
    :ok
  end
end
