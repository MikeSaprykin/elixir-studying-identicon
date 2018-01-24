defmodule Identicon do
  @moduledoc """
  A module for generation of the identicon depending on the input string
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squared
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, filename) do
    File.write("images/#{filename}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    %Identicon.Image{image | pixel_map: grid |> Enum.map(&generate_coordinates/1)}
  end

  def generate_coordinates({_code, index}) do
    horizontal = rem(index, 5) * 50
    vertical = div(index, 5) * 50
    top_left = {horizontal, vertical}
    bottom_left = {horizontal + 50, vertical + 50}
    {top_left, bottom_left}
  end

  def filter_odd_squared(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _i} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end
end
