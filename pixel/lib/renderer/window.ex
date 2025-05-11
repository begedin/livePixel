defmodule Pixel.Renderer.Window do
  defstruct [:frame, :canvas, :context]

  @type t :: %__MODULE__{
          frame: :wxFrame.wxFrame(),
          canvas: :wxGLCanvas.wxGLCanvas(),
          context: :wxGLContext.wxGLContext()
        }

  @spec init(width :: pos_integer(), height :: pos_integer()) :: t()
  def init(width, height) do
    opts = [size: {width, height}]

    wx = :wx.new()

    frame = :wxFrame.new(wx, :wx_const.wx_id_any(), ~c"Experiments", opts)

    :wxWindow.connect(frame, :close_window)

    :wxFrame.show(frame)

    gl_attrib = [
      attribList: [
        :wx_const.wx_gl_core_profile(),
        :wx_const.wx_gl_major_version(),
        4,
        :wx_const.wx_gl_minor_version(),
        1,
        :wx_const.wx_gl_doublebuffer(),
        # :wx_const.wx_gl_depth_size, 24,
        :wx_const.wx_gl_sample_buffers(),
        1,
        :wx_const.wx_gl_samples(),
        4,
        0
      ]
    ]

    canvas = :wxGLCanvas.new(frame, opts ++ gl_attrib)
    ctx = :wxGLContext.new(canvas)

    :wxGLCanvas.setFocus(canvas)
    :wxGLCanvas.setCurrent(canvas, ctx)
    :wxGLCanvas.connect(canvas, :mousewheel)

    %__MODULE__{
      frame: frame,
      canvas: canvas,
      context: ctx
    }
  end

  def set_current(%__MODULE__{} = window) do
    :wxGLCanvas.setCurrent(window.canvas, window.context)
  end

  def swap_buffers(%__MODULE__{} = window) do
    :wxGLCanvas.swapBuffers(window.canvas)
  end
end
