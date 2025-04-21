defmodule Pixel.Renderer do
  def clear_frame(r, g, b, a) do
    :gl.clearColor(r, g, b, a)
    :gl.clear(:gl_const.gl_color_buffer_bit())
  end

  @spec swap_buffers(any()) :: boolean()
  def swap_buffers(window) do
    :wxGLCanvas.swapBuffers(window.canvas)
  end
end
