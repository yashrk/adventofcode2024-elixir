#!/usr/bin/elixir

defmodule Solution do
  def solution({keys, locks}) do
    for k <- keys, l <- locks do
      Enum.zip([k, l])
    end
    |> Enum.filter(&check/1)
  end

  def separator({:key, key}, {keys, locks}) do
    {[key|keys], locks}
  end

  def separator({:lock, lock}, {keys, locks}) do
    {keys, [lock|locks]}
  end

  def parser("", {:new, :unknown, []}=state), do: state

  def parser("", {:lock, lock, objects}) do
    {:new, :unknown, [{:lock, lock} | objects]}
  end

  def parser("", {:key, key, objects}) do
    key = Enum.map(key, &(&1-1))
    {:new, :unknown, [{:key, key} | objects]}
  end

  def parser("#####", {:new, :unknown, objects}) do
    {:lock, [0, 0, 0, 0, 0], objects}
  end

  def parser(".....", {:new, :unknown, objects}) do
    {:key, [0, 0, 0, 0, 0], objects}
  end

  def parser(str, {:lock, cur, objects}) do
    cur =
      Enum.zip(String.graphemes(str), cur)
      |> Enum.map(fn
        {".", n} -> n
        {"#", n} -> n + 1
      end)

    {:lock, cur, objects}
  end

  def parser(str, {:key, cur, objects}) do
    cur =
      Enum.zip(String.graphemes(str), cur)
      |> Enum.map(fn
        {".", n} -> n
        {"#", n} -> n + 1
      end)

    {:key, cur, objects}
  end

  def check(combination) do
    Enum.all?(
      combination,
      fn ({k, l}) -> k+l < 6 end
    )
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.reduce(
  {:new, :unknown, []},
  &Solution.parser/2
)
|> elem(2)
|> Enum.reduce({[], []}, &Solution.separator/2)
|> Solution.solution()
|> Enum.count()
|> IO.inspect()
