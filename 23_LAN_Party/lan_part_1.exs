#!/usr/bin/elixir

defmodule Solution do
  @r_conn ~r"(\w\w)-(\w\w)"
  def parse_connection(str) do
    [[_str, node_1, node_2]] = Regex.scan(@r_conn, str)
    {node_1, node_2}
  end

  def update_graph({node_1, node_2}, graph) do
    graph = Map.update(graph, node_1, [node_2], &([node_2|&1]))
    Map.update(graph, node_2, [node_1], &([node_1|&1]))
  end

  def to_cliques(graph) do
    for n <- graph do
      find_cliques(n, graph)
    end
    |> List.flatten()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sort/1)
    |> MapSet.new()
  end

  def find_cliques({node, neighbours}, graph) do
    for n_1 <- neighbours, n_2 <- neighbours do
      if n_1 in graph[n_2] do
        [{node, n_1, n_2}]
      else
        []
      end
    end
    |> Enum.filter(&(not Enum.empty? &1))
    |> Enum.filter(&contains_t_name/1)
    |> List.flatten()
  end

  def contains_t_name([{n_1, n_2, n_3}]) do
    Enum.any?([n_1, n_2, n_3], &(String.match?(&1, ~r"t\w")))
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.map(&Solution.parse_connection/1)
|> Enum.reduce(%{}, &Solution.update_graph/2)
|> Solution.to_cliques()
|> Enum.count()
|> IO.inspect()
