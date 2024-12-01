#!/usr/bin/elixir

defmodule Solution do
  def count_reducer(num, acc) do
    Map.update(acc, num, 1, &(&1 + 1))
  end

  def get_pairs(str, acc) do
    String.trim(str)
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer(&1))
    |> then(fn [l, r] -> [{l, r} | acc] end)
  end
end

{l, r} =
  IO.stream()
  |> Enum.reduce([], &Solution.get_pairs/2)
  |> Enum.unzip()

r_counts = Enum.reduce(r, %{}, &Solution.count_reducer/2)

Enum.reduce(l, 0, &(Map.get(r_counts, &1, 0) * &1 + &2))
|> Integer.to_string()
|> IO.puts()
