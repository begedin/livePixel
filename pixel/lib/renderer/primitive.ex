defmodule Pixel.Renderer.Primitive do
  alias Pixel.Renderer.Shader
  defstruct [:shader, :vao, :vbo, :type]

  def new(type, shader) when type in [:triangle_strip, :rectangle] and is_integer(shader) do
    %__MODULE__{
      shader: shader,
      vao: :gl.genVertexArrays(1) |> hd(),
      vbo: :gl.genBuffers(1) |> hd(),
      type: type
    }
  end

  def draw(%__MODULE__{type: :triangle_strip} = primitive, vertices) do
    Shader.use_shader(primitive.shader)

    :gl.bindVertexArray(primitive.vao)
    :gl.bindBuffer(:gl_const.gl_array_buffer(), primitive.vbo)

    buffer =
      Enum.reduce(vertices, <<>>, fn {x, y, z}, acc ->
        acc <> <<x::float-little-32, y::float-little-32, z::float-little-32>>
      end)

    :gl.bufferData(
      :gl_const.gl_array_buffer(),
      byte_size(buffer),
      buffer,
      :gl_const.gl_static_draw()
    )

    :gl.vertexAttribPointer(
      0,
      3,
      :gl_const.gl_float(),
      :gl_const.gl_false(),
      0,
      0
    )

    :gl.enableVertexAttribArray(0)

    :gl.drawArrays(:gl_const.gl_triangles(), 0, length(vertices))

    :gl.bindVertexArray(0)
    :gl.bindBuffer(:gl_const.gl_array_buffer(), 0)
  end

  def draw(%__MODULE__{type: :rectangle} = primitive, rectangles) do
    vertices = Enum.flat_map(rectangles, &rect_to_vertices/1)
    draw(%{primitive | type: :triangle_strip}, vertices)
  end

  # we render rectangles by converting them into a triangle strip
  defp rect_to_vertices({x, y, w, h}) do
    [
      # First triangle; top-left, top-right, bottom-right
      {x, y, 0.0},
      {x + w, y, 0.0},
      {x + w, y + h, 0.0},
      # Second triangle; top-left, bottom-right, bottom-left
      {x, y, 0.0},
      {x + w, y + h, 0.0},
      {x, y + h, 0.0}
    ]
  end
end
