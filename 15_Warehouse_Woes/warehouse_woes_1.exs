#!/usr/bin/elixir

Mix.install([:arrays])

defmodule Solution do
  def boxes_gps(map) do
    for y <- 0..(Arrays.size(map) - 1),
        x <- 0..(Arrays.size(map) - 1) do
      {x, y}
    end
    |> Enum.filter(fn {x, y} -> map[y][x] == "O" end)
    |> Enum.map(fn {x, y} -> y * 100 + x end)
    |> Enum.sum()
  end

  def command_reducer(command, map) do
    [{rx, ry}] = find_robot(map)
    execute_command(command, {{rx, ry}, map})
  end

  def find_robot(map) do
    for y <- 0..(Arrays.size(map) - 1),
        x <- 0..(Arrays.size(map) - 1) do
      {x, y}
    end
    |> Enum.filter(fn {x, y} -> map[y][x] == "@" end)
  end

  def execute_command("^", {{rx, ry}, map}) do
    push(map, {rx, ry}, 0, -1, ["@"])
    |> then(&if length(&1) > 0, do: ["." | &1], else: &1)
    |> update(map, {rx, ry}, 0, -1)
  end

  def execute_command("v", {{rx, ry}, map}) do
    push(map, {rx, ry}, 0, 1, ["@"])
    |> then(&if length(&1) > 0, do: ["." | &1], else: &1)
    |> update(map, {rx, ry}, 0, 1)
  end

  def execute_command("<", {{rx, ry}, map}) do
    push(map, {rx, ry}, -1, 0, ["@"])
    |> then(&if length(&1) > 0, do: ["." | &1], else: &1)
    |> update(map, {rx, ry}, -1, 0)
  end

  def execute_command(">", {{rx, ry}, map}) do
    push(map, {rx, ry}, 1, 0, ["@"])
    |> then(&if length(&1) > 0, do: ["." | &1], else: &1)
    |> update(map, {rx, ry}, 1, 0)
  end

  def push(map, {x, y}, dx, dy, queue) do
    case map[y + dy][x + dx] do
      "#" ->
        []

      "." ->
        queue

      "O" ->
        queue = queue ++ ["O"]
        push(map, {x + dx, y + dy}, dx, dy, queue)
    end
  end

  def update([], map, {_x, _y}, _dx, _dy), do: map

  def update([cur | queue], map, {x, y}, dx, dy) do
    map =
      Arrays.replace(
        map,
        y,
        Arrays.replace(map[y], x, cur)
      )

    update(queue, map, {x + dx, y + dy}, dx, dy)
  end

  def input_reducer("", {:map, map, program}), do: {:program, map, program}

  def input_reducer(str, {:map, map, program}) do
    new_line =
      String.graphemes(str)
      |> then(&(&1 |> Enum.into(Arrays.new())))

    {:map, Arrays.append(map, new_line), program}
  end

  def input_reducer(str, {:program, map, program}) do
    {:program, map, program <> str}
  end

  def show_map(map) do
    for y <- 0..(Arrays.size(map) - 1),
        x <- 0..(Arrays.size(map) - 1) do
      IO.write(map[y][x])
      if x == Arrays.size(map) - 1, do: IO.write("\n")
    end
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.reduce(
  {
    :map,
    Arrays.new(
      [],
      implementation: Arrays.Implementations.ErlangArray
    ),
    ""
  },
  &Solution.input_reducer/2
)
|> then(fn {_state, map, program} ->
  String.graphemes(program)
  |> Enum.reduce(
    map,
    &Solution.command_reducer/2
  )
end)
|> Solution.boxes_gps()
|> IO.inspect()
