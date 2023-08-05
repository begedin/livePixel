defmodule LivePixelWeb.DemosLive do
  use LivePixelWeb, :live_view

  def render(assigns) do
    ~H"""
    <.link navigate={~p"/snake"}>Snake</.link>
    """
  end
end
