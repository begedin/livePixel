defmodule Pixel.Renderer.OpenGL do
  alias Pixel.Math.Mat4

  def init() do
    do_enables()

    :gl.blendFunc(:gl_const.gl_src_alpha(), :gl_const.gl_one_minus_src_alpha())
  end

  defp do_enables() do
    # :gl.enable(:gl_const.gl_depth_test)
    # :gl.enable(:gl_const.gl_cull_face)
    :gl.enable(:gl_const.gl_multisample())
    :gl.enable(:gl_const.gl_blend())
  end

  def set_2d(w, h) do
    projection = Mat4.ortho(0.0, w + 0.0, h + 0.0, 0.0, -1.0, 1.0)

    [_, _, fb_width, fb_height | _] = :gl.getIntegerv(:gl_const.gl_viewport())
    :gl.viewport(0, 0, fb_width, fb_height)

    projection
  end
end
