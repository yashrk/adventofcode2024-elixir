#!/usr/bin/elixir

Mix.install([:arrays])

defmodule Solution do
  def solution(garden) do
    last = Arrays.size(garden) - 1
    idxs = for x <- 0..last, y <- 0..last, do: {x, y}

    Enum.reduce(
      idxs,
      {garden, Map.new(), Map.new(), MapSet.new()},
      &garden_reducer/2
    )
    |> count_price()
  end

  def garden_reducer({x, y}, {garden, areas, perimeters, visited}) do
    plot = garden[y][x]

    if {x, y} in visited do
      {garden, areas, perimeters, visited}
    else
      {perimeter, area, visited} = dfs(garden, {x, y}, visited, plot)
      perimeters = Map.put(perimeters, {x, y}, perimeter)
      areas = Map.put(areas, {x, y}, area)
      {garden, areas, perimeters, visited}
    end
  end

  def count_price({_garden, areas, perimeters, _visited}) do
    Map.to_list(perimeters)
    |> Enum.reduce(
      0,
      fn {{x, y}, perimeter}, price ->
        price + areas[{x, y}] * perimeter
      end
    )
  end

  def dfs(garden, {x, y}, visited, plant) do
    last = Arrays.size(garden)

    cond do
      {x, y} in visited ->
        {0, 0, visited}

      x < 0 or x > last or y < 0 or y > last ->
        {0, 0, visited}

      garden[y][x] != plant ->
        {0, 0, visited}

      true ->
        visited = MapSet.put(visited, {x, y})

        neighbours =
          [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

        fences =
          neighbours
          |> Enum.filter(fn {nx, ny} ->
            nx < 0 or
              nx > last or
              ny < 0 or
              ny > last or
              garden[ny][nx] != garden[y][x]
          end)
          |> Enum.count()

        neighbours
        |> Enum.filter(&(&1 not in visited))
        |> Enum.reduce(
          {fences, 1, visited},
          fn {x, y}, {cur_fences, area, visited} ->
            {count, new_area, visited} =
              dfs(garden, {x, y}, visited, plant)

            {cur_fences + count, area + new_area, visited}
          end
        )
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
