#!/usr/bin/elixir

defmodule Solution do
  def safe_with_dampener?(report) do
    safe_report?(report) or
      Enum.any?(
        Enum.map(
          subreports(report),
          &safe_report?/1
        )
      )
  end

  def safe_report?(report) do
    {res, _prev, _dir} =
      Enum.reduce_while(
        tl(report),
        {true, hd(report), :unknown},
        &safe?/2
      )

    res
  end

  def subreports(report) do
    for i <- 0..(length(report)-1) do
      Enum.take(report, i) ++ Enum.drop(report, i + 1)
    end
  end

  def extract_report(str) do
    String.trim(str)
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def safe?(cur, {_, prev, prev_diff}) do
    cond do
      good_diff?(cur, prev, prev_diff) and
          good_levels?(cur, prev) ->
        {:cont, {true, cur, diff(cur, prev)}}

      true ->
        {:halt, {false, cur, :unknown}}
    end
  end

  def good_diff?(cur, prev, :increasing) when cur < prev, do: false
  def good_diff?(cur, prev, :decreasing) when cur > prev, do: false
  def good_diff?(_, _, _), do: true

  def good_levels?(a, b) when abs(a - b) < 1, do: false
  def good_levels?(a, b) when abs(a - b) > 3, do: false
  def good_levels?(_, _), do: true

  def diff(cur, prev) when cur > prev, do: :increasing
  def diff(cur, prev) when cur < prev, do: :decreasing
  def diff(_, _), do: :unknown
end

IO.stream()
|> Enum.map(&Solution.extract_report/1)
|> Enum.map(&Solution.safe_with_dampener?/1)
|> Enum.reduce(0, &(if &1, do: &2+1, else: &2))
|> IO.inspect()
