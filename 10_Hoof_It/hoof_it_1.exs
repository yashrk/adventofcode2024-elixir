#!/usr/bin/elixir

Mix.install([:arrays])

defmodule Solution do
  # Magic number -- char
  # code before 0, ?/
  @start 47

  def solution(map) do
    last = Arrays.size(map) - 1

    for y <- 0..last, x <- 0..last do
      if map[y][x] == ?0 do
        dfs(map, x, y, @start)
        |> Enum.uniq()
        |> Enum.count()
      else
        0
      end
    end
    |> Enum.sum()
  end

  def dfs(map, cur_x, cur_y, _prev) do
    size = Arrays.size(map)

    cond do
      map[cur_y][cur_x] == ?. ->
        []

      map[cur_y][cur_x] == ?9 ->
        [{cur_x, cur_y}]

      true ->
        for y <- (cur_y - 1)..(cur_y + 1),
            x <- (cur_x - 1)..(cur_x + 1),
            x == cur_x or y == cur_y do
          {x, y}
        end
        |> Enum.filter(fn {x, y} ->
          x >= 0 and
            x < size and
            y >= 0 and
            y < size
        end)
        |> Enum.filter(fn {x, y} ->
          map[y][x] - map[cur_y][cur_x] == 1
        end)
        |> Enum.map(fn {x, y} ->
          dfs(map, x, y, map[cur_y][cur_x])
        end)
        |> List.flatten()
    end
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_charlist/1)
|> Enum.map(&(&1 |> Enum.into(Arrays.new())))
|> Enum.reduce(Arrays.new(), &Arrays.append(&2, &1))
|> Solution.solution()
|> IO.inspect()
