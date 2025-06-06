defmodule LivePixelWeb.SnakeLive do
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
      |> push_event("setup", Game.config())
      |> push_event("assets", Game.assets())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-full w-full flex place-items-center justify-center">
      <div class="relative flex max-w-full max-h-full items-center justify-center aspect-square">

      <div
        class="flex place-items-center justify-center aspect-square"
        tabindex="0"
        phx-hook="pixi"
        id="game"
        phx-window-keydown="keydown"
        phx-target="#game"
        phx-update="ignore"
      >
      </div>
      <div phx-hook="howler" id="sound" class="display-none" ></div>
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
end
