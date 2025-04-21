defmodule LivePixelWeb.DemosLive do
  use LivePixelWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex items-center justify-center gap-4">
      <.link class="p-8 text-xl bg-emerald-200 hover:bg-emerald-300 transition-colors flex rounded-md" navigate={~p"/snake"}>Snake</.link>
      <.link class="p-8 text-xl bg-emerald-200 hover:bg-emerald-300 transition-colors flex rounded-md" navigate={~p"/snake-svg"}>Snake SVG</.link>
    </div>
    """
  end
end
