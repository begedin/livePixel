defmodule Pixel.Loop do
  @moduledoc """
  Process module for running a game loop.

  Provides setup boilerplate for the game and defines a :wx_object process
  """

  defmacro __using__(opts) do
    quote do
      @behaviour Pixel.Game

      @loop_opts unquote(opts)

      def child_spec(_arg \\ []) do
        %{
          id: __MODULE__,
          start: {Pixel.Loop, :start_link, [__MODULE__, @loop_opts]},
          restart: :transient,
          shutdown: 500
        }
      end

      def start_link do
        Pixel.Loop.start_link(__MODULE__, @loop_opts)
      end
    end
  end

  import Pixel.WxRecords

  alias Pixel.Renderer.OpenGL
  alias Pixel.Renderer.Window

  def start_link(mod, opts) do
    game_opts =
      Map.merge(
        %{
          game_id: mod,
          screen_size: {opts[:width] || 800, opts[:height] || 800},
          render_interval: opts[:render_interval] || div(1000, 60)
        },
        Map.new(opts)
      )

    Task.start_link(fn ->
      {:wx_ref, _, :wxFrame, pid} =
        :wx_object.start_link({:local, mod}, __MODULE__, {mod, game_opts}, [])

      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, ^pid, _reason} -> :ok
      end
    end)
  end

  defstruct game_id: nil,
            keys: MapSet.new(),
            screen_size: {800, 800},
            user_mod: nil,
            user_state: nil,
            window: nil

  def init({user_mod, opts}) do
    {width, height} = opts[:screen_size]

    window = Window.init(width, height)

    OpenGL.init()
    OpenGL.set_2d()

    user_state = user_mod.init(opts)

    loop_pid = self()

    handle_input = fn
      wx(event: wxKey(type: type, x: _x, y: _y, keyCode: key_code)), _wx_state ->
        :wx_object.cast(loop_pid, {type, key_code})
    end

    :wxGLCanvas.connect(window.canvas, :key_down,
      callback: fn wx_req, wx_state -> handle_input.(wx_req, wx_state) end
    )

    :wxGLCanvas.connect(window.canvas, :key_up,
      callback: fn wx_req, wx_state -> handle_input.(wx_req, wx_state) end
    )

    :timer.send_interval(opts[:render_interval], :render)
    send(self(), :update)

    state =
      %__MODULE__{
        game_id: opts[:game_id],
        screen_size: opts[:screen_size],
        keys: [],
        user_mod: user_mod,
        user_state: user_state,
        window: window
      }

    {window.frame, state}
  end

  def handle_event(wx(event: wxClose()), state) do
    :wxWindow."Destroy"(state.window.frame)
    {:stop, :normal, state}
  end

  def handle_info(:render, state) do
    Window.set_current(state.window)
    user_state = apply(state.user_mod, :render, [state.user_state])
    Window.swap_buffers(state.window)

    {:noreply, %{state | user_state: user_state}}
  end

  def handle_info(:update, state) do
    user_state = apply(state.user_mod, :update, [state.user_state, state.keys])
    send(self(), :update)
    {:noreply, %{state | user_state: user_state}}
  end

  def terminate(reason, state) do
    apply(state.user_mod, :terminate, [reason, state.user_state])

    :ok
  end

  def handle_call(_msg, _from, state), do: {:noreply, state}

  def handle_cast({:key_down, keycode}, state) do
    keys = Enum.uniq([keycode | state.keys])
    {:noreply, %{state | keys: keys}}
  end

  def handle_cast({:key_up, keycode}, state) do
    keys = List.delete(state.keys, keycode)
    {:noreply, %{state | keys: keys}}
  end

  def handle_cast(_msg, state), do: {:noreply, state}
end
