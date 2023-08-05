defmodule LivePixelWeb.SnakeLive do
  use LivePixelWeb, :live_view

  def mount(_, _, socket) do
    player_id = Snake.Utils.new_id()

    if connected?(socket) do
      Application.put_env(:ecsx, :tick_rate, 4)
      Application.put_env(:ecsx, :persist_interval, :timer.seconds(50000))
      Snake.Manager.start_link([])
      ECSx.ClientEvents.add(player_id, :spawn)
      :timer.send_interval(20, :send_update)
    end

    {:ok, assign(socket, page_title: "Snake", player_id: player_id)}
  end

  def render(assigns) do
    ~H"""
    <div tabindex="0" phx-hook="pixi" id="game" phx-keydown="keydown" phx-target="#game" />
    """
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    ECSx.ClientEvents.add(socket.assigns.player_id, {:keydown, key})
    {:noreply, socket}
  end

  def handle_info(:send_update, socket) do
    {:noreply, push_event(socket, "update", %{world: Snake.Manager.get_world()})}
  end
end
