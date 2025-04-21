defmodule Snake.GLGame do
  @behaviour :wx_object

  import Snake.GL.WxRecords

  require Logger

  alias Renderer.Primitive
  alias Renderer.Font
  alias Audio.SoundEffect
  alias Math.Mat4
  alias Renderer.OpenGL
  alias Renderer.Shader
  alias Renderer.Sprite
  alias Renderer.Texture2D
  alias Renderer.Utils
  alias Renderer.Window
  alias Snake.Controller
  alias Snake.Game

  @screen_width 800
  @screen_height 800

  @spec child_spec(any()) :: %{
          id: Snake.GLGame,
          restart: :temporary,
          significant: true,
          start: {Snake.GLGame, :start_link, [...]}
        }
  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]},
      significant: true,
      restart: :temporary
    }
  end

  @impl :wx_object
  def init([]) do
    window = Window.init(@screen_width, @screen_height)

    :wxGLCanvas.connect(window.canvas, :key_down, callback: &handle_input/2)
    :wxGLCanvas.connect(window.canvas, :key_up, callback: &handle_input/2)

    log_gl_info()

    OpenGL.init()

    projection = Mat4.ortho(0.0, @screen_width + 0.0, @screen_height + 0.0, 0.0, -1.0, 1.0)
    [_, _, fb_width, fb_height | _] = :gl.getIntegerv(:gl_const.gl_viewport())
    :gl.viewport(0, 0, fb_width, fb_height)

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

    state = %{
      window: window,
      game_state: Game.spawn_player(%{}),
      score: 0,
      width: @screen_width,
      height: @screen_height,
      sprite_shader: sprite_shader,
      sprite_renderer: sprite_renderer,
      body_chunk: body_chunk,
      keys: MapSet.new(),
      font: font
    }

    :timer.send_interval(floor(1000 / 60), :render)
    send(self(), :update)

    {window.frame, state}
  end

  def start do
    :wx_object.start_link(__MODULE__, [], [])
  end

  def start_link(arg) do
    :wx_object.start_link({:local, __MODULE__}, __MODULE__, arg, [])
    {:ok, self()}
  end

  @impl :wx_object
  def terminate(reason, state) do
    Logger.error(msg: reason)
    System.halt(0)

    {:shutdown, state}
  end

  @impl :wx_object
  @spec handle_event({:wx, any(), any(), any(), {:wxClose, any()}}, any()) ::
          {:stop, :normal, any()}
  def handle_event(wx(event: wxClose()), state) do
    :wxWindow."Destroy"(state.window.frame)

    {:stop, :normal, state}
  end

  @impl :wx_object
  def handle_call(_request, _from, state) do
    {:noreply, state}
  end

  @impl :wx_object
  def handle_cast({:key_down, key_code}, state) do
    Logger.info("key_down: #{key_code}")
    state = %{state | keys: MapSet.put(state.keys, key_code)}
    {:noreply, state}
  end

  def handle_cast({:key_up, key_code}, state) do
    Logger.info("key_up: #{key_code}")
    state = %{state | keys: MapSet.delete(state.keys, key_code)}

    {:noreply, state}
  end

  @impl :wx_object
  def handle_info(:start_profiling, state) do
    :tprof.start(%{type: :call_time})
    :tprof.enable_trace(:all)
    :tprof.set_pattern(:_, :_, :_)
    # :eprof.start_profiling([self()])
    # :eprof.log(~c'eprof')
    Process.send_after(self(), :stop_profiling, 10_000)
    {:noreply, state}
  end

  def handle_info(:stop_profiling, state) do
    :tprof.disable_trace(:all)
    sample = :tprof.collect()
    inspected = :tprof.inspect(sample, :process, :measurement)
    shell = :maps.get(self(), inspected)

    IO.puts(:tprof.format(shell))

    # :eprof.stop_profiling()
    # :eprof.analyze()
    {:noreply, state}
  end

  def handle_info(:render, %{} = state) do
    %{world: world, sound: sound} = Game.render(state.game_state)
    if sound, do: SoundEffect.play(sound)

    game_state = Snake.Systems.SoundCleanup.run(state.game_state)

    :gl.clearColor(0.5, 0.0, 1.0, 1.0)
    :gl.clear(:gl_const.gl_color_buffer_bit())

    # === Rectangle Rendering ===

    rectangles =
      Enum.map(world, fn rect ->
        {rect["x"] * rect["width"], rect["y"] * rect["height"], rect["width"], rect["height"]}
      end)

    Primitive.draw(state.body_chunk, rectangles)

    Font.draw(state.font, "#{Game.score(state.game_state)}", 740, 10, 1.0)

    # === Swap Buffers ===
    :wxGLCanvas.swapBuffers(state.window.canvas)

    {:noreply, %{state | game_state: game_state}}
  end

  def handle_info(:update, %{} = state) do
    game_state = state.game_state

    game_state =
      cond do
        MapSet.member?(state.keys, :wx_const.wxk_space()) ->
          Controller.run(game_state, {:keydown, " "})

        MapSet.member?(state.keys, :wx_const.wxk_left()) ->
          Controller.run(game_state, {:keydown, "ArrowLeft"})

        MapSet.member?(state.keys, :wx_const.wxk_right()) ->
          Controller.run(game_state, {:keydown, "ArrowRight"})

        MapSet.member?(state.keys, :wx_const.wxk_up()) ->
          Controller.run(game_state, {:keydown, "ArrowUp"})

        MapSet.member?(state.keys, :wx_const.wxk_down()) ->
          Controller.run(game_state, {:keydown, "ArrowDown"})

        true ->
          game_state
      end

    game_state =
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

    send(self(), :update)

    {:noreply, %{state | game_state: game_state}}
  end

  defp log_gl_info do
    IO.puts("🧠 OpenGL Info:")
    IO.puts("🔹 Version: #{:gl.getString(:gl_const.gl_version())}")
    IO.puts("🔹 Renderer: #{:gl.getString(:gl_const.gl_renderer())}")
    IO.puts("🔹 Vendor: #{:gl.getString(:gl_const.gl_vendor())}")
    IO.puts("🔹 GLSL: #{:gl.getString(:gl_const.gl_shading_language_version())}")
  end

  def handle_input(
        wx(event: wxKey(type: type, x: _x, y: _y, keyCode: key_code)) = _request,
        state
      ) do
    :wx_object.cast(__MODULE__, {type, key_code})
    {:noreply, state}
  end
end
