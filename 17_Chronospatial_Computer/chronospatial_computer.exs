#!/usr/bin/elixir

Mix.install([:arrays])

defmodule Solution do
  @adv 0
  @bxl 1
  @bst 2
  @jnz 3
  @bxc 4
  @out 5
  @bdv 6
  @cdv 7

  @ra 4
  @rb 5
  @rc 6

  def execute_program(machine) do
    if machine[:ip] == Arrays.size(machine[:program]) do
      machine[:output]
      |> Enum.reverse()
      |> print_result()
    else
      machine = machine_step(machine)
      execute_program(machine)
    end
  end

  def parse_program(strs) do
    {_state, program} =
      Enum.reduce(
        strs,
        {
          :register_a,
          %{
            a: 0,
            b: 0,
            c: 0,
            ip: 0,
            program: Arrays.new(),
            output: []
          }
        },
        &program_parser/2
      )

    program
  end

  def machine_step(machine) do
    case machine[:program][machine[:ip]] do
      @adv ->
        %{adv(machine) | ip: machine[:ip] + 2}

      @bxl ->
        %{bxl(machine) | ip: machine[:ip] + 2}

      @bst ->
        %{bst(machine) | ip: machine[:ip] + 2}

      @jnz ->
        jnz(machine)

      @bxc ->
        %{bxc(machine) | ip: machine[:ip] + 2}

      @out ->
        %{out(machine) | ip: machine[:ip] + 2}

      @bdv ->
        %{bdv(machine) | ip: machine[:ip] + 2}

      @cdv ->
        %{cdv(machine) | ip: machine[:ip] + 2}

      opcode ->
        IO.puts("Wrong opcode: #{opcode}")
        machine
    end
  end

  @register_a ~r"Register A: (\d+)"
  def program_parser(str, {:register_a, machine}) do
    [[a]] =
      Regex.scan(@register_a, str, capture: :all_but_first)

    machine = %{machine | a: String.to_integer(a)}
    {:register_b, machine}
  end

  @register_b ~r"Register B: (\d+)"
  def program_parser(str, {:register_b, machine}) do
    [[b]] =
      Regex.scan(@register_b, str, capture: :all_but_first)

    machine = %{machine | b: String.to_integer(b)}
    {:register_c, machine}
  end

  @register_c ~r"Register C: (\d+)"
  def program_parser(str, {:register_c, machine}) do
    [[c]] =
      Regex.scan(@register_c, str, capture: :all_but_first)

    machine = %{machine | c: String.to_integer(c)}
    {:delimiter, machine}
  end

  def program_parser("", {:delimiter, machine}) do
    {:program, machine}
  end

  @program ~r"Program: (.*)"
  def program_parser(str, {:program, machine}) do
    [[code]] =
      Regex.scan(@program, str, capture: :all_but_first)

    program =
      String.split(code, ",")
      |> Enum.map(&String.to_integer/1)
      |> Arrays.new()

    machine = %{machine | program: program}
    {:finish, machine}
  end

  def adv(machine) do
    res =
      (machine[:a] / 2 ** get_combo_operand(machine))
      |> trunc()

    %{machine | a: res}
  end

  def bxl(machine) do
    res = Bitwise.bxor(machine[:b], get_literal_operand(machine))
    %{machine | b: res}
  end

  def bst(machine) do
    res = rem(get_combo_operand(machine), 8)
    %{machine | b: res}
  end

  def jnz(machine) do
    if machine[:a] == 0 do
      %{machine | ip: machine[:ip] + 2}
    else
      %{machine | ip: get_literal_operand(machine)}
    end
  end

  def bxc(machine) do
    res = Bitwise.bxor(machine[:b], machine[:c])
    %{machine | b: res}
  end

  def out(machine) do
    res =
      get_combo_operand(machine)
      |> rem(8)

    %{machine | output: [res | machine[:output]]}
  end

  def bdv(machine) do
    res =
      (machine[:a] / 2 ** get_combo_operand(machine))
      |> trunc()

    %{machine | b: res}
  end

  def cdv(machine) do
    res =
      (machine[:a] / 2 ** get_combo_operand(machine))
      |> trunc()

    %{machine | c: res}
  end

  def get_literal_operand(machine) do
    machine[:program][machine[:ip] + 1]
  end

  def get_combo_operand(machine) do
    case machine[:program][machine[:ip] + 1] do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      @ra -> machine[:a]
      @rb -> machine[:b]
      @rc -> machine[:c]
    end
  end

  def print_result([n]) do
    IO.write("#{n}\n")
  end

  def print_result([n|output]) do
    IO.write("#{n},")
    print_result(output)
  end

end

IO.stream()
|> Enum.map(&String.trim/1)
|> Solution.parse_program()
|> Solution.execute_program()
|> IO.inspect()
