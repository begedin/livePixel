defmodule Pixel.Renderer.OpenGL do
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

  def set_2d() do
    [_, _, fb_width, fb_height | _] = :gl.getIntegerv(:gl_const.gl_viewport())
    :gl.viewport(0, 0, fb_width, fb_height)
  end

  def log_info do
    IO.puts("🧠 OpenGL Info:")
    IO.puts("🔹 Version: #{:gl.getString(:gl_const.gl_version())}")
    IO.puts("🔹 Renderer: #{:gl.getString(:gl_const.gl_renderer())}")
    IO.puts("🔹 Vendor: #{:gl.getString(:gl_const.gl_vendor())}")
    IO.puts("🔹 GLSL: #{:gl.getString(:gl_const.gl_shading_language_version())}")
  end
end
