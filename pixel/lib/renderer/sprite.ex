defmodule Pixel.Renderer.Sprite do
  alias Pixel.Math.Mat4
  alias Pixel.Math.Vec3
  alias Pixel.Renderer.Shader
  alias Pixel.Renderer.Texture2D
  alias Pixel.Renderer.Utils

  defstruct [:shader, :quadVAO]

  def new(shader) do
    init_render_data(%__MODULE__{shader: shader})
  end

  def draw(
        # %__MODULE__{shader: shader} = sprite,
        %{sprite_renderer: %{shader: shader} = sprite} = _state,
        texture,
        {x, y} = _position,
        {width, height} = _size,
        rotate,
        color
      ) do
    Shader.use_shader(shader)

    model =
      Mat4.identity()
      |> Mat4.translate(Vec3.new(x, y, 0))
      |> Mat4.translate(Vec3.new(0.5 * width, 0.5 * height, 0))
      |> Mat4.rotate(rotate, Vec3.new(0, 0, 1))
      |> Mat4.translate(Vec3.new(-0.5 * width, -0.5 * height, 0))
      |> Mat4.scale_vec(Vec3.new(width, height, 1))
      |> Mat4.transpose()

    Shader.set(shader, ~c"model", [model |> Mat4.flatten()])
    Shader.set(shader, ~c"spriteColor", color)

    :gl.activeTexture(:gl_const.gl_texture0())
    Texture2D.bind(texture)

    :gl.bindVertexArray(sprite.quadVAO)
    :gl.drawArrays(:gl_const.gl_triangles(), 0, 6)

    :gl.bindVertexArray(0)
  end

  defp init_render_data(%__MODULE__{} = sprite) do
    [quadVAO] = :gl.genVertexArrays(1)
    sprite = %__MODULE__{sprite | quadVAO: quadVAO}

    vertices =
      Utils.make_bits([
        0.0,
        1.0,
        0.0,
        1.0,
        1.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        0.0,
        1.0,
        0.0
      ])

    [vbo] = :gl.genBuffers(1)

    :gl.bindBuffer(:gl_const.gl_array_buffer(), vbo)

    :gl.bufferData(
      :gl_const.gl_array_buffer(),
      byte_size(vertices),
      vertices,
      :gl_const.gl_static_draw()
    )

    :gl.bindVertexArray(quadVAO)
    :gl.enableVertexAttribArray(0)

    :gl.vertexAttribPointer(
      0,
      4,
      :gl_const.gl_float(),
      :gl_const.gl_false(),
      4 * byte_size(<<0::native-float-size(32)>>),
      0
    )

    :gl.bindBuffer(:gl_const.gl_array_buffer(), 0)
    :gl.bindVertexArray(0)

    sprite
  end
end
