#!/usr/bin/elixir

Mix.install([:arrays])

defmodule Solution do
  def checksum(disk_map) do
    0..Arrays.size(disk_map)-1
    |> Enum.map(&({&1, disk_map[&1]}))
    |> Enum.filter(&(elem(&1, 1) != "."))
    |> Enum.map(fn {index, val} ->
      index * String.to_integer(val)
    end)
    |> Enum.sum()
  end
  
  def defrag(disk_map, free, file) when free>=file, do: disk_map
  def defrag(disk_map, free, file) do
    cond do
      disk_map[free] == "." and
      disk_map[file] != "." ->
        disk_map = Arrays.replace(disk_map, free, disk_map[file])
        disk_map = Arrays.replace(disk_map, file, ".")
        defrag(disk_map, free+1, file-1)
      disk_map[free] != "." -> defrag(disk_map, free+1, file)
      disk_map[file] == "." -> defrag(disk_map, free, file-1)
    end
  end

  def blocks(blockstring) do
    Enum.reduce(
      String.graphemes(blockstring),
      {
        :file,
        Arrays.new(
          [],
          implementation: Arrays.Implementations.ErlangArray
        ),
        0
      },
      &block_reducer/2
    )
  end

  def block_reducer(c, {:file, res, id}) do
    count = String.to_integer(c)

    {
      :free,
      for(_ <- 1..count//1, do: ".")
      |> Enum.reduce(
        res,
        fn _, acc ->
          Arrays.append(acc, "#{id}")
        end
      ),
      id
    }
  end

  def block_reducer(c, {:free, res, id}) do
    count = String.to_integer(c)

    {
      :file,
      for(_ <- 1..count//1, do: ".")
      |> Enum.reduce(
        res,
        &Arrays.append(&2, &1)
      ),
      id + 1
    }
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> hd
|> Solution.blocks()
|> elem(1)
|> then(&Solution.defrag(&1, 0, Arrays.size(&1) - 1))
|> Solution.checksum()
|> IO.inspect()
