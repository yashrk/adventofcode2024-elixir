#!/usr/bin/elixir

defmodule Solution do
  def solve(gates) do
    zs = extract_zs(gates)
    gates = eval_top(zs, gates)

    zs
    |> Enum.reduce(
      {1, 0},
      fn {gate, _}, {pw, res} ->
        {:value, val} = gates[gate]
        res = Bitwise.bor(val * pw, res)
        {pw * 2, res}
      end
    )
    |> elem(1)
  end

  def eval_top([], gates), do: gates

  def eval_top([{gate, {:op, op, dep_1, dep_2}} | tail] = stack, gates) do
    case {gates[dep_1], gates[dep_2]} do
      {{:value, v_1}, {:value, v_2}} ->
        gates = Map.put(gates, gate, {:value, eval(op, v_1, v_2)})
        eval_top(tail, gates)

      {{:op, _, _, _} = d_1, {:value, _}} ->
        eval_top([{dep_1, d_1} | stack], gates)

      {{:value, _}, {:op, _, _, _} = d_2} ->
        eval_top([{dep_2, d_2} | stack], gates)

      {{:op, _, _, _} = d_1, {:op, _, _, _} = d_2} ->
        stack = [{dep_1, d_1}, {dep_2, d_2} | stack]
        eval_top(stack, gates)
    end
  end

  def eval("AND", v_1, v_2), do: Bitwise.band(v_1, v_2)
  def eval("OR", v_1, v_2), do: Bitwise.bor(v_1, v_2)
  def eval("XOR", v_1, v_2), do: Bitwise.bxor(v_1, v_2)

  def parser("", {:values, gates}), do: {:gates, gates}

  @val_regex ~r"(\w\w\w): (\d)"
  def parser(str, {:values, gates}) do
    [[gate, val]] = Regex.scan(@val_regex, str, capture: :all_but_first)
    {:values, Map.put(gates, gate, {:value, String.to_integer(val)})}
  end

  @gate_regex ~r"(\w\w\w) (\w+) (\w\w\w) -> (\w\w\w)"
  def parser(str, {:gates, gates}) do
    [[dep_1, op, dep_2, gate]] =
      Regex.scan(@gate_regex, str, capture: :all_but_first)

    {:gates, Map.put(gates, gate, {:op, op, dep_1, dep_2})}
  end

  def extract_zs(gates) do
    Enum.filter(
      gates,
      fn {gate, _} ->
        String.match?(gate, ~r"z.*")
      end
    )
    |> Enum.sort()
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.reduce({:values, %{}}, &Solution.parser/2)
|> elem(1)
|> Solution.solve()
|> IO.inspect()
