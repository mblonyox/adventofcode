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
    |> then(&Map.replace!(map, start, &1))

  map
  |> Map.to_list()
  |> length()
  |> Range.new(0)
  |> Enum.reduce({0, [{start, %MapSet{}}]}, fn _, {max, list} ->
    list
    |> Enum.flat_map(fn {pos, history} ->
      history
      |> MapSet.member?(pos)
      |> Kernel.or(!Map.has_key?(map, pos))
      |> then(&MapSet.to_list(history))
    end)
  end)

  #     case Map.get(map, pos) do
  #       nil ->
  #         history |> MapSet.to_list() |> length() |> then(&[&1])

  #       list ->
  #         list
  #         |> Enum.map(fn next ->
  #           history
  #           |> MapSet.member?(next)
  #           |> if do
  #             history |> MapSet.to_list() |> length()
  #           else
  #             {next, MapSet.put(history, pos)}
  #           end
  #         end)
  #     end
  #   end)
  #   |> Enum.
  # end)
end

__ENV__.file
|> Aoc2023.input_stream()
|> then(parse_input)
|> then(traverse_map)
|> IO.inspect(label: "Result")
