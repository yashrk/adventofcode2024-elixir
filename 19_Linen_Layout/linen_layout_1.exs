#!/usr/bin/elixir

defmodule Solution do
  def solution({patterns, designs}) do
    :ets.new(:memo, [:named_table])

    res =
      Enum.map(designs, &count_patterns(&1, patterns))
      |> Enum.filter(&(&1 != 0))
      |> Enum.count()

    :ets.delete(:memo)
    res
  end

  def parse_input(strings) do
    {patterns, desings, _state} =
      Enum.reduce(
        strings,
        {[], [], :patterns},
        &input_reducer/2
      )

    {patterns, Enum.reverse(desings)}
  end

  def input_reducer(str, {[], [], :patterns}) do
    patterns =
      String.split(str, ",")
      |> Enum.map(&String.trim/1)

    {patterns, [], :delimiter}
  end

  def input_reducer("", {patterns, [], :delimiter}) do
    {patterns, [], :designs}
  end

  def input_reducer(design, {patterns, designs, :designs}) do
    {patterns, [design | designs], :designs}
  end

  def count_patterns("", _patterns), do: 1

  def count_patterns(design, patterns) do
    prev = :ets.lookup(:memo, design)

    case prev do
      [{^design, count}] ->
        count

      [] ->
        matches =
          Enum.map(
            patterns,
            fn pattern ->
              {head, tail} =
                String.split_at(
                  design,
                  String.length(pattern)
                )

              if head == pattern do
                [head, tail]
              else
                []
              end
            end
          )
          |> Enum.filter(&(not Enum.empty?(&1)))

        res =
          if Enum.empty?(matches) do
            0
          else
            Enum.map(matches, &Enum.at(&1, 1))
            |> Enum.map(&count_patterns(&1, patterns))
            |> Enum.sum()
          end

        :ets.insert(:memo, {design, res})
        res
    end
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Solution.parse_input()
|> Solution.solution()
|> IO.inspect()
