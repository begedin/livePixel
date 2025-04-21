defmodule Pixel do
  @moduledoc """
  Documentation for `Pixel`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Pixel.hello()
      :world

  """
  def log_gl_info do
    IO.puts("🧠 OpenGL Info:")
    IO.puts("🔹 Version: #{:gl.getString(:gl_const.gl_version())}")
    IO.puts("🔹 Renderer: #{:gl.getString(:gl_const.gl_renderer())}")
    IO.puts("🔹 Vendor: #{:gl.getString(:gl_const.gl_vendor())}")
    IO.puts("🔹 GLSL: #{:gl.getString(:gl_const.gl_shading_language_version())}")
  end
end
