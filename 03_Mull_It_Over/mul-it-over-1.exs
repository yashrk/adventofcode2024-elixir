#!/usr/bin/elixir

IO.stream()
|> Enum.map(&Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, &1))
|> List.flatten()
|> Enum.map(&Regex.scan(~r/\d+/, &1))
|> Enum.map(fn l ->
  List.flatten(l)
  |> Enum.map(&String.to_integer/1)
  |> then(&(hd(&1) * hd(tl(&1))))
end)
|> Enum.sum()
|> IO.inspect()
