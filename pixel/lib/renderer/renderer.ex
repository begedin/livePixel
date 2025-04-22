defmodule Pixel.Renderer do
  def clear_frame(r, g, b, a) do
    :gl.clearColor(r, g, b, a)
    :gl.clear(:gl_const.gl_color_buffer_bit())
  end
end
