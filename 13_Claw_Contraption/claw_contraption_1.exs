#!/usr/bin/elixir

defmodule Solution do
  def price(steps) do
    steps[:a]*3 + steps[:b]
  end
  
  def solutions(machine) do
    a_max_x = max(div(machine[:prize_x], machine[:a_x]), 100)
    a_max_y = max(div(machine[:prize_y], machine[:a_y]), 100)
    b_max_x = max(div(machine[:prize_x], machine[:b_x]), 100)
    b_max_y = max(div(machine[:prize_y], machine[:b_y]), 100)
    a_max = min(a_max_x, a_max_y)
    b_max = min(b_max_x, b_max_y)
    for a <- 0..a_max, b <- 0..b_max do
      %{a: a, b: b}
    end
    |> Enum.filter(fn steps ->
      steps[:a]*machine[:a_x]+steps[:b]*machine[:b_x] == machine[:prize_x] and
      steps[:a]*machine[:a_y]+steps[:b]*machine[:b_y] == machine[:prize_y]
    end)
  end

  @a_line ~r"Button A: X\+(\d+), Y\+(\d+)"
  def machine_reducer(str, {:a, machines}) do
    [[a_x, a_y]] =
      Regex.scan(@a_line, str, capture: :all_but_first)
    {:b,
     [%{a_x: String.to_integer(a_x),
        a_y: String.to_integer(a_y)}
      | machines]
    }
  end

  @b_line ~r"Button B: X\+(\d+), Y\+(\d+)"
  def machine_reducer(str, {:b, [machine|machines]}) do
    [[b_x, b_y]] =
      Regex.scan(@b_line, str, capture: :all_but_first)
    machine =
      Map.put(machine, :b_x, String.to_integer(b_x))
    machine =
      Map.put(machine, :b_y, String.to_integer(b_y))
    {:prize, [machine|machines]}
  end

  @prize_line ~r"Prize: X=(\d+), Y=(\d+)"
  def machine_reducer(str, {:prize, [machine|machines]}) do
    [[prize_x, prize_y]] =
      Regex.scan(@prize_line, str, capture: :all_but_first)
    machine =
      Map.put(machine, :prize_x, String.to_integer(prize_x))
    machine =
      Map.put(machine, :prize_y, String.to_integer(prize_y))
    {:delimiter, [machine|machines]}
  end

  def machine_reducer("", {:delimiter, machines}), do: {:a, machines}
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.reduce({:a, []}, &Solution.machine_reducer/2)
|> then(&(elem(&1, 1)))
|> Enum.map(&Solution.solutions/1)
|> List.flatten()
|> Enum.map(&Solution.price/1)
|> Enum.sum()
|> IO.inspect()
