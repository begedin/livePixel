-module(wx_const).
-compile(nowarn_export_all).
-compile(export_all).

-include_lib("wx/include/wx.hrl").


wx_id_any() -> ?wxID_ANY.
wx_gl_rgba() -> ?WX_GL_RGBA.

wx_gl_doublebuffer() -> ?WX_GL_DOUBLEBUFFER.
wx_gl_depth_size() -> ?WX_GL_DEPTH_SIZE.
wx_gl_forward_compat() -> ?WX_GL_FORWARD_COMPAT.

% keyboard mappings/macros

wxk_left() -> ?WXK_LEFT.
wxk_right() -> ?WXK_RIGHT.
wxk_up() -> ?WXK_UP.
wxk_down() -> ?WXK_DOWN.
wxk_space() -> ?WXK_SPACE.
wxk_raw_control() -> ?WXK_RAW_CONTROL.


wx_gl_major_version() -> ?WX_GL_MAJOR_VERSION.
wx_gl_minor_version() -> ?WX_GL_MINOR_VERSION.
wx_gl_core_profile() -> ?WX_GL_CORE_PROFILE.
wx_gl_sample_buffers() -> ?WX_GL_SAMPLE_BUFFERS.
wx_gl_samples() -> ?WX_GL_SAMPLES.
wx_gl_min_red() -> ?WX_GL_MIN_RED.
wx_gl_min_green() -> ?WX_GL_MIN_GREEN.
wx_gl_min_blue() -> ?WX_GL_MIN_BLUE.

wx_null_cursor() -> ?wxNullCursor.
wx_cursor_blank() -> ?wxCURSOR_BLANK.
wx_cursor_cross() -> ?wxCURSOR_CROSS.

wx_fontfamily_default() -> ?wxFONTFAMILY_DEFAULT.
wx_fontfamily_teletype() -> ?wxFONTFAMILY_TELETYPE.
wx_normal() -> ?wxNORMAL.
wx_fontstyle_normal() -> ?wxFONTSTYLE_NORMAL.
wx_fontweight_bold() -> ?wxFONTWEIGHT_BOLD.
wx_fontweight_normal() -> ?wxFONTWEIGHT_NORMAL.


