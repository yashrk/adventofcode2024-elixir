#!/usr/bin/elixir

defmodule Solution do
  def solution_reducer({:ok, res}, sum) do
    sum + res
  end

  def solution_reducer({:error, _reason}, sum) do
    sum
  end

  def find_solution({result, equation}) do
    ops = operators(length(equation) - 1)
    answers = Enum.map(ops, &calculate(equation, &1))

    if result in answers do
      {:ok, result}
    else
      {:error, "No solution"}
    end
  end

  def calculate(args, ops) do
    {_, res} = Enum.reduce(ops, {tl(args), hd(args)}, &op_reducer/2)
    res
  end

  def op_reducer("*", {[arg | args], res}) do
    {args, arg * res}
  end

  def op_reducer("+", {[arg | args], res}) do
    {args, arg + res}
  end

  def operators(0) do
    [[]]
  end

  def operators(n) do
    ops_prev = operators(n - 1)

    Enum.map(ops_prev, &["*" | &1]) ++
      Enum.map(ops_prev, &["+" | &1])
  end

  def parse_equation(str) do
    [result, operands] = String.split(str, ~r":", trim: true)
    result = String.to_integer(result)

    operands =
      String.split(operands, " ", trim: true)
      |> Enum.map(&String.to_integer/1)

    {result, operands}
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.map(&Solution.parse_equation/1)
|> Enum.map(&Solution.find_solution/1)
|> Enum.reduce(0, &Solution.solution_reducer/2)
|> IO.inspect()
