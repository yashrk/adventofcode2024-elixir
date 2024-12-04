#!/usr/bin/elixir

IO.stream()
|> Enum.reduce("", &(&2 <> &1))
|> then(&Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/, &1))
|> then(&(Enum.reduce(&1, {:enabled, 0}, fn
  ["do()"], {_, acc} -> {:enabled, acc}
  ["don't()"], {_, acc} -> {:disabled, acc}
  [_mul, a, b], {:enabled, acc} ->
    res = String.to_integer(a) * String.to_integer(b)
    {:enabled, acc+res}
  _cur, {:disabled, acc} -> {:disabled, acc}
end)))
|> then(&(elem(&1, 1)))
|> IO.inspect()
