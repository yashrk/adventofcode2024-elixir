#!/usr/bin/elixir

defmodule Solution do
  def diff_reducer(left, right, acc) do
    acc + abs(left - right)
  end

  def get_pairs(str, acc) do
    String.trim(str)
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer(&1))
    |> then(fn [l, r] -> [{l, r} | acc] end)
  end
end

IO.stream()
|> Enum.reduce([], &Solution.get_pairs/2)
|> Enum.unzip()
|> then(fn {l, r} -> {Enum.sort(l), Enum.sort(r)} end)
|> then(fn {l, r} ->
  Enum.zip_reduce(l, r, 0, &Solution.diff_reducer/3)
end)
|> IO.puts()
