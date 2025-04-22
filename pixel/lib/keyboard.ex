defmodule Pixel.Keyboard do
  def pressed?(keys, " "), do: Enum.member?(keys, :wx_const.wxk_space())
  def pressed?(keys, "Space"), do: Enum.member?(keys, :wx_const.wxk_space())
  def pressed?(keys, "ArrowLeft"), do: Enum.member?(keys, :wx_const.wxk_left())
  def pressed?(keys, "ArrowRight"), do: Enum.member?(keys, :wx_const.wxk_right())
  def pressed?(keys, "ArrowUp"), do: Enum.member?(keys, :wx_const.wxk_up())
  def pressed?(keys, "ArrowDown"), do: Enum.member?(keys, :wx_const.wxk_down())

  # ascii
  def pressed?(keys, "P"), do: Enum.member?(keys, 80)
  def pressed?(keys, "p"), do: Enum.member?(keys, 112)

  def first_pressed(pressed_keys, supported_keys) do
    Enum.find(supported_keys, fn key -> pressed?(pressed_keys, key) end)
  end
end
