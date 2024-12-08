#!/usr/bin/elixir

defmodule Solution do
  def coords_reducer(str, {row, antennas}) do
    {_charnum, antennas} =
      Enum.reduce(
        String.graphemes(str),
        {0, antennas},
        fn
          ".", {col, antennas} ->
            {col + 1, antennas}

          char, {col, antennas} ->
            {col + 1,
             Map.update(
               antennas,
               char,
               [{col, row}],
               &[{col, row} | &1]
             )}
        end
      )

    {row + 1, antennas}
  end

  def find_antinodes({size, antennas}) do
    Enum.into(antennas, %{}, &Solution.calculate_antinodes(&1, size))
  end

  def calculate_antinodes({type, antennas}, size) do
    antennas = Enum.sort(antennas)

    antinodes =
      for {x_1, y_1} = a <- antennas, {x_2, y_2} = b <- antennas, a < b do
        dx = x_2 - x_1
        dy = y_2 - y_1
        [a, b | harmonics(a, -dx, -dy, size)] ++ [harmonics(b, dx, dy, size)]
      end
      |> List.flatten()
      |> Enum.filter(fn {x, y} -> x >= 0 and x < size and y >= 0 and y < size end)

    {type, antinodes}
  end

  def harmonics({x, _y}, _dx, _dy, _size) when x <= 0, do: []
  def harmonics({_x, y}, _dx, _dy, _size) when y <= 0, do: []
  def harmonics({x, _y}, _dx, _dy, size) when x >= size, do: []
  def harmonics({_x, y}, _dx, _dy, size) when y >= size, do: []

  def harmonics({x, y}, dx, dy, size) do
    new_x = x + dx
    new_y = y + dy
    new_antinode = {new_x, new_y}
    [new_antinode | harmonics(new_antinode, dx, dy, size)]
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.reduce({0, %{}}, &Solution.coords_reducer/2)
|> Solution.find_antinodes()
|> Enum.map(&(elem(&1, 1)))
|> List.flatten()
|> Enum.uniq()
|> Enum.count()
|> IO.inspect()
