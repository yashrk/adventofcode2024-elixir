#!/usr/bin/elixir

defmodule Solution do
  require Integer

  def blink_n_times(stones, n) do
    Enum.reduce(1..n, stones, fn _, s -> blink(s) end)
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
|> Solution.blink_n_times(1)
|> Enum.count()
|> IO.inspect()
