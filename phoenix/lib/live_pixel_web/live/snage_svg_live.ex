defmodule LivePixelWeb.SnakeSVGLive do
  use LivePixelWeb, :live_view

  alias Snake.Game
  alias Snake.Controller

  require Logger

  def mount(_, _, socket) do
    if connected?(socket) do
      :timer.send_interval(floor(1000 / 60), :draw)
      send(self(), :update)
    end

    socket =
      socket
      |> assign(page_title: "Snake", game_state: Game.spawn_player(%{}), score: 0)
      |> push_event("assets", Game.assets())

    {:ok, socket}
  end

  def render(assigns) do
    config = Game.config()

    assigns =
      assign(
        assigns,
        render_state: Game.render(assigns.game_state),
        game_width: config.width,
        game_height: config.height
      )

    ~H"""
    <div class="h-full w-full flex place-items-center justify-center">
      <div class="relative flex max-w-full max-h-full items-center justify-center aspect-square">

      <div
        class="flex place-items-center justify-center aspect-square w-full h-full"
        tabindex="0"
        id="game"
        phx-window-keydown="keydown"
        phx-target="#game"
        phx-hook="howler"
      >
        <svg
          class="w-[800px] h-[800px] bg-black"
          viewBox={"0 0 #{@game_width} #{@game_height}"}
        >
          <rect
            :for={entity <- @render_state.world}
            x={entity["x"] * entity["width"]} y={entity["y"] * entity["height"]}
            width={entity["width"]} height={entity["height"]}
            fill={"#{rgb_to_hex(entity["color"])}"} />
          />
        </svg>
      </div>
      <div
        :if={Game.game_over?(@game_state)}
        class="absolute w-full h-full bg-red-600/50 grid text-white text-xl place-items-center">
          <div>Game Over</div>
          <button phx-click="new_game">Try again</button>
        </div>
      <div
        :if={Game.paused?(@game_state)}
        class="absolute w-full h-full bg-white/50 grid text-xl place-items-center">
        Pause (hit "Space" to continue)
      </div>
      <div class="absolute top-0 right-0 p-4 text-white text-xl">
        <div>{@score}</div>
      </div>
      </div>
    </div>
    """
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    state = Controller.run(socket.assigns.game_state, {:keydown, key})
    {:noreply, assign(socket, :game_state, state)}
  end

  def handle_event("new_game", _, socket) do
    state = Game.spawn_player(%{})
    {:noreply, assign(socket, :game_state, state)}
  end

  def handle_info(:draw, socket) do
    game_state = Snake.Systems.SoundCleanup.run(socket.assigns.game_state)

    socket =
      socket
      |> push_event("state", Game.render(socket.assigns.game_state))
      |> assign(:game_state, game_state)

    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    IO.inspect(
      {Game.game_over?(socket.assigns.game_state), Game.playing?(socket.assigns.game_state)}
    )

    state =
      if Game.playing?(socket.assigns.game_state) do
        socket.assigns.game_state
        |> Snake.Systems.Movement.run()
        |> Snake.Systems.Animation.run()
        |> Snake.Systems.Collision.run()
        |> Snake.Systems.FoodEating.run()
        |> Snake.Systems.FoodSpawning.run()
      else
        socket.assigns.game_state
      end

    send(self(), :update)

    {:noreply, assign(socket, game_state: state, score: Game.score(state))}
  end

  defp rgb_to_hex(%{r: r, g: g, b: b})
       when is_integer(r) and r in 0..255 and
              is_integer(g) and g in 0..255 and
              is_integer(b) and b in 0..255 do
    r_hex = Integer.to_string(r, 16) |> String.pad_leading(2, "0")
    g_hex = Integer.to_string(g, 16) |> String.pad_leading(2, "0")
    b_hex = Integer.to_string(b, 16) |> String.pad_leading(2, "0")
    "##{r_hex}#{g_hex}#{b_hex}"
  end
end
