#!/usr/bin/elixir

defmodule Solution do
  require Integer

  def blink_immediatelly(stones, n) do
    :ets.new(:memo, [:named_table])
    res = Enum.map(stones, &blink_n_times(&1, n))
    :ets.delete(:memo)
    res
  end

  def blink_n_times(_stone, 0) do
    1
  end

  def blink_n_times(stone, n) do
    prev = :ets.lookup(:memo, {stone, n})

    if length(prev) > 0 do
      hd(prev) |> elem(1)
    else
      new_stones = blink([stone])
      res = 
        Enum.map(
          new_stones,
          &(blink_n_times(&1, n-1))
        )
        |> Enum.sum()

      :ets.insert(:memo, {{stone, n}, res})
      res
    end
  end

  def blink(stones) do
    Enum.map(stones, &Solution.apply_rules/1)
    |> List.flatten()
  end

  def apply_rules(stone) do
    stone_str = "#{stone}"
    l = String.length(stone_str)

    cond do
      stone == 0 ->
        [1]

      Integer.is_even(l) ->
        two_stones(stone_str, l)

      true ->
        [stone * 2024]
    end
  end

  def two_stones(stone, l) do
    {a, b} = String.split_at(stone, div(l, 2))
    [String.to_integer(a), String.to_integer(b)]
  end

  def output(stones) do
    Enum.reduce(tl(stones), "#{hd(stones)}", &(&2 <> " #{&1}"))
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> hd
|> String.split(" ")
|> Enum.map(&String.to_integer/1)
|> Solution.blink_immediatelly(75)
|> Enum.sum()
|> IO.puts()
