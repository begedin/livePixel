defmodule Renderer.Font do
  @moduledoc "Font renderer for ascii_rgb.png (256x94, 16x6 ASCII layout)"
  alias Renderer.Texture2D
  alias Renderer.Shader

  @cols 16
  @rows 6
  @tex_width 256
  @tex_height 96

  @char_width @tex_width / @cols
  @char_height @tex_height / @rows

  # Default size in screen-space for each character
  @screen_char_w 32
  @screen_char_h 32

  defstruct [:shader, :texture, :vao, :vbo]

  @type t :: %__MODULE__{
          shader: Shader.t(),
          texture: Texture2D.t(),
          vao: integer(),
          vbo: integer()
        }

  def new(shader, %Texture2D{} = texture) when is_integer(shader) do
    %__MODULE__{
      shader: shader,
      texture: texture,
      vao: :gl.genVertexArrays(1) |> hd(),
      vbo: :gl.genBuffers(1) |> hd()
    }
  end

  def draw(%__MODULE__{} = font, str, start_x, start_y, scale \\ 1.0) do
    Texture2D.bind(font.texture)

    Shader.use_shader(font.shader)
    Shader.set(font.shader, ~c"u_font", 0)
    Shader.set(font.shader, ~c"u_color", {1.0, 1.0, 1.0})

    # Set the texture unit to 0
    :gl.activeTexture(:gl_const.gl_texture0())

    :gl.bindVertexArray(font.vao)
    :gl.bindBuffer(:gl_const.gl_array_buffer(), font.vbo)

    buffer = text_to_buffer(str, start_x, start_y, scale)

    :gl.bufferData(
      :gl_const.gl_array_buffer(),
      byte_size(buffer),
      buffer,
      :gl_const.gl_static_draw()
    )

    # 5 floats per vertex (x, y, z, u, v)
    stride = 5 * 4

    # Position attribute
    :gl.vertexAttribPointer(0, 3, :gl_const.gl_float(), :gl_const.gl_false(), stride, 0)
    :gl.enableVertexAttribArray(0)

    # UV attribute
    :gl.vertexAttribPointer(1, 2, :gl_const.gl_float(), :gl_const.gl_false(), stride, 12)
    :gl.enableVertexAttribArray(1)

    # 5 floats * 4 bytes = 20 bytes per vertex
    vertex_count = div(byte_size(buffer), stride)
    :gl.drawArrays(:gl_const.gl_triangles(), 0, vertex_count)

    :gl.bindVertexArray(0)
    :gl.bindBuffer(:gl_const.gl_array_buffer(), 0)
  end

  @doc """
  Converts a string into a vertex buffer (x, y, z, u, v) ready for OpenGL
  """
  def text_to_buffer(str, start_x, start_y, scale \\ 1.0) do
    str
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.flat_map(fn {char, i} ->
      if char >= 32 and char <= 126 do
        x = start_x + i * @screen_char_w * scale
        y = start_y
        w = @screen_char_w * scale
        h = @screen_char_h * scale
        uv = uv_coords(char)
        quad(x, y, w, h, uv)
      else
        # skip unsupported char
        []
      end
    end)
    |> pack_buffer()
  end

  defp uv_coords(char) do
    index = char - 32
    col = rem(index, @cols)
    row = div(index, @cols)
    u0 = col / @cols
    v0 = row / @rows
    u1 = (col + 1) / @cols
    v1 = (row + 1) / @rows
    %{u0: u0, v0: v0, u1: u1, v1: v1}
  end

  defp quad(x, y, w, h, %{u0: u0, v0: v0, u1: u1, v1: v1}) do
    [
      # triangle 1
      {x, y, 0.0, u0, v0},
      {x + w, y, 0.0, u1, v0},
      {x + w, y + h, 0.0, u1, v1},

      # triangle 2
      {x, y, 0.0, u0, v0},
      {x + w, y + h, 0.0, u1, v1},
      {x, y + h, 0.0, u0, v1}
    ]
  end

  defp pack_buffer(vertices) do
    Enum.reduce(vertices, <<>>, fn {x, y, z, u, v}, acc ->
      acc <>
        <<x::float-little-32, y::float-little-32, z::float-little-32, u::float-little-32,
          v::float-little-32>>
    end)
  end
end
