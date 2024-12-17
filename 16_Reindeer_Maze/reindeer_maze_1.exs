#!/usr/bin/elixir

Mix.install([:arrays, :heap])

defmodule Solution do
  @walk 1
  @turn_and_walk 1001

  def score(map) do
    {start_x, start_y} = find_start(map)

    map =
      Arrays.replace(
        map,
        start_y,
        Arrays.replace(map[start_y], start_x, ".")
      )

    visited = MapSet.new([{start_x, start_y}])
    heap = Heap.new(&price_comparator/2)
    heap = Heap.push(heap, {start_x, start_y, :e, 0})
    dijkstra(map, heap, visited)
  end

  def dijkstra(map, heap, visited) do
    {x, y, dir, price} = Heap.root(heap)
    heap = Heap.pop(heap)
    visited = MapSet.put(visited, {x, y})

    case map[y][x] do
      "E" ->
        price

      "." ->
        heap =
          Enum.reduce(
            neighbours(map, {x, y, dir, price}, visited),
            heap,
            &Heap.push(&2, &1)
          )

        dijkstra(map, heap, visited)
    end
  end

  def neighbours(map, {x, y, _dir, _price} = cur, visited) do
    size_x = Arrays.size(map[0])
    size_y = Arrays.size(map)

    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(fn {x, y} ->
      x >= 0 and
        x < size_x and
        y >= 0 and
        y < size_y
    end)
    |> Enum.filter(fn {x, y} ->
      {x, y} not in visited
    end)
    |> Enum.filter(fn {x, y} ->
      map[y][x] != "#"
    end)
    |> Enum.map(&add_price(cur, &1))
  end

  def price_comparator({_x_1, _y_1, _dir_1, price_1}, {_x_2, _y_2, _dir_2, price_2}) do
    price_1 < price_2
  end

  # N -> N
  def add_price({cx, _cy, :n, price}, {nx, ny}) when cx == nx do
    {nx, ny, :n, price + @walk}
  end

  # N -> E
  def add_price({cx, cy, :n, price}, {nx, ny}) when cy == ny and nx > cx do
    {nx, ny, :e, price + @turn_and_walk}
  end

  # N -> W
  def add_price({_cx, _cy, :n, price}, {nx, ny}) do
    {nx, ny, :w, price + @turn_and_walk}
  end

  # S -> S
  def add_price({cx, _cy, :s, price}, {nx, ny}) when cx == nx do
    {nx, ny, :s, price + @walk}
  end

  # S -> E
  def add_price({cx, cy, :s, price}, {nx, ny}) when cy == ny and nx > cx do
    {nx, ny, :e, price + @turn_and_walk}
  end

  # S -> W
  def add_price({_cx, _cy, :s, price}, {nx, ny}) do
    {nx, ny, :w, price + @turn_and_walk}
  end

  # E -> E
  def add_price({_cx, cy, :e, price}, {nx, ny}) when cy == ny do
    {nx, ny, :e, price + @walk}
  end

  # E -> N
  def add_price({cx, cy, :e, price}, {nx, ny}) when cx == nx and ny < cy do
    {nx, ny, :n, price + @turn_and_walk}
  end

  # E -> S
  def add_price({_cx, _cy, :e, price}, {nx, ny}) do
    {nx, ny, :s, price + @turn_and_walk}
  end

  # W -> W
  def add_price({_cx, cy, :w, price}, {nx, ny}) when cy == ny do
    {nx, ny, :w, price + @walk}
  end

  # W -> N
  def add_price({cx, cy, :w, price}, {nx, ny}) when cx == nx and ny < cy do
    {nx, ny, :n, price + @turn_and_walk}
  end

  # W -> S
  def add_price({_cx, _cy, :w, price}, {nx, ny}) do
    {nx, ny, :s, price + @turn_and_walk}
  end

  def find_start(map) do
    size_y = Arrays.size(map)
    {1, size_y - 2}
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.map(&String.graphemes/1)
|> Enum.map(&(&1 |> Enum.into(Arrays.new())))
|> Enum.reduce(Arrays.new(), &Arrays.append(&2, &1))
|> Solution.score()
|> IO.inspect()
