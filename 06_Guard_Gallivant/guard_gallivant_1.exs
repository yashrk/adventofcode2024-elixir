#!/usr/bin/elixir

Mix.install([:arrays])

defmodule Solution do
  def solution(area) do
    {x, y} = find_guard(area)
    move_guard(area, {:north, {x, y}}, MapSet.new())
    |> MapSet.size()
  end

  def find_guard(area) do
    Enum.reduce_while(area, {0, 0}, fn row, {x, y} ->
      size_x = Arrays.size(row)

      case Enum.reduce_while(row, {x, y}, &guard_reducer/2) do
        {x, y} when x == size_x -> {:cont, {0, y + 1}}
        {x, y} -> {:halt, {x, y}}
      end
    end)
  end

  def move_guard(area, {direction, {x, y}} = guard, visited) do
    size_x = Arrays.size(area[0])
    size_y = Arrays.size(area)
    ahead = move(guard)
    {_direction, ahead_coords} = ahead

    cond do
      out?({x, y}, {size_x, size_y}) ->
        visited

      obstacle?(area, ahead_coords) ->
        move_guard(area, {turn_right(direction), {x, y}}, visited)

      true ->
        move_guard(area, ahead, MapSet.put(visited, {x, y}))
    end
  end

  def guard_reducer(tile, {x, y}) do
    if tile == ?^ do
      {:halt, {x, y}}
    else
      {:cont, {x + 1, y}}
    end
  end

  def out?({-1, _y}, {_size_x, _size_y}), do: true
  def out?({size_x, _y}, {size_x, _size_y}), do: true
  def out?({_x, -1}, {_size_x, _size_y}), do: true
  def out?({_x, size_y}, {_size_x, size_y}), do: true
  def out?({_, _}, {_, _}), do: false

  def move({:north, {x, y}}), do: {:north, {x, y - 1}}
  def move({:east, {x, y}}), do: {:east, {x + 1, y}}
  def move({:south, {x, y}}), do: {:south, {x, y + 1}}
  def move({:west, {x, y}}), do: {:west, {x - 1, y}}

  def turn_right(:north), do: :east
  def turn_right(:east), do: :south
  def turn_right(:south), do: :west
  def turn_right(:west), do: :north

  def obstacle?(area, {x, y}) do
    area[y][x] == ?#
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_charlist/1)
|> Enum.map(&(&1 |> Enum.into(Arrays.new())))
|> Enum.reduce(Arrays.new(), &Arrays.append(&2, &1))
|> Solution.solution()
|> IO.inspect()
