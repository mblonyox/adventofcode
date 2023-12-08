defmodule Navigator do
  def parse_input(stream) do
    stream
    |> Enum.reduce({nil, %{}}, fn e, {nav, networks} = acc ->
      case Regex.scan(~r/[A-Z]+/, e) do
        [[n], [l], [r]] -> {nav, Map.put(networks, n, {l, r})}
        [[nav]] -> {nav, networks}
        _ -> acc
      end
    end)
  end

  def navigate({nav, networks} = input, node \\ "AAA", steps \\ 0) do
    reducer = fn lr, {node, steps} ->
      networks[node]
      |> elem((lr == "R" && 1) || 0)
      |> case do
        "ZZZ" -> {:halt, steps + 1}
        node -> {:cont, {node, steps + 1}}
      end
    end

    nav
    |> String.split("", trim: true)
    |> Enum.reduce_while({node, steps}, reducer)
    |> case do
      {node, steps} -> navigate(input, node, steps)
      steps -> steps
    end
  end
end

__ENV__.file
|> Aoc2023.input_stream()
|> Navigator.parse_input()
|> Navigator.navigate()
|> IO.inspect(label: "Result")
