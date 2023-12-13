parse_input = fn stream ->
  stream
  |> Stream.with_index()
  |> Stream.flat_map(fn {line, row} ->
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {c, col} ->
      {
        {row, col},
        case c do
          "|" -> [{row - 1, col}, {row + 1, col}]
          "-" -> [{row, col - 1}, {row, col + 1}]
          "L" -> [{row - 1, col}, {row, col + 1}]
          "J" -> [{row - 1, col}, {row, col - 1}]
          "7" -> [{row, col - 1}, {row + 1, col}]
          "F" -> [{row, col + 1}, {row + 1, col}]
          "S" -> :start
          _ -> nil
        end
      }
    end)
    |> Enum.reject(&is_nil(elem(&1, 1)))
  end)
  |> Map.new()
end

traverse_map = fn map ->
  start =
    map
    |> Map.to_list()
    |> Enum.find(&(elem(&1, 1) == :start))
    |> then(&elem(&1, 0))

  map =
    map
    |> Map.delete(start)
    |> Map.to_list()
    |> Enum.filter(&(elem(&1, 1) |> Enum.member?(start)))
    |> Enum.map(&elem(&1, 0))
    |> then(&Map.replace(map, start, &1))

  map
  |> Map.to_list()
  |> length()
  |> then(&(0..&1))
  |> Enum.reduce_while({[start], [start]}, fn steps, {positions, history} ->
    if Enum.empty?(positions) do
      {:halt, steps - 1}
    else
      positions
      |> Enum.flat_map(&Map.get(map, &1, []))
      |> Enum.reject(&Enum.member?(history, &1))
      |> then(&{&1, Enum.concat(&1, history)})
      |> then(&{:cont, &1})
    end
  end)
end

__ENV__.file
|> Aoc2023.input_stream()
|> then(parse_input)
|> then(traverse_map)
|> IO.inspect(label: "Result")
