defmodule Pixel.Renderer.Utils do
  def make_bits(list) do
    list
    |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::float-native-size(32)>> end)
  end

  def make_bits_little(list) do
    list
    |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::float-little-size(32)>> end)
  end

  def make_bits_unsigned(list) do
    list
    |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::unsigned-native-size(32)>> end)
  end
end
