parse_numbers = fn numbers ->
  numbers
  |> String.split(~r/\s+/, trim: true)
  |> Enum.map(&String.to_integer/1)
end

parse_mapping = fn [dest, src, len] ->
  {src..(src + len - 1), dest - src}
end

parse_line = fn line, {sect, list} = acc ->
  case line |> String.trim() |> String.split([":", " map:"]) do
    [""] -> {:cont, acc, {nil, []}}
    ["seeds", nums] -> {:cont, {"seeds", parse_numbers.(nums)}}
    [sect, ""] -> {:cont, {sect, []}}
    [nums] -> parse_numbers.(nums) |> then(parse_mapping) |> then(&{:cont, {sect, [&1 | list]}})
  end
end

process_almanac = fn [{"seeds", seeds} | maps] ->
  seeds =
    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, len] -> start..(start + len - 1) end)

  maps
  |> Enum.map(fn {_, list} -> list end)
  |> Enum.reduce(seeds, fn list, acc ->
    acc
    |> Enum.flat_map(fn range ->
      list
      |> Enum.flat_map(fn {src, _} -> [src.first - 1, src.first, src.last, src.last + 1] end)
      |> Enum.filter(&(&1 >= range.first and &1 <= range.last))
      |> Enum.concat([range.first, range.last])
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.chunk_every(2)
      |> Enum.map(fn [first, last] ->
        range = first..last

        list
        |> Enum.find_value(range, fn {src, delta} ->
          if !Range.disjoint?(src, range), do: Range.shift(range, delta), else: nil
        end)
      end)
    end)
  end)
  |> Enum.map(& &1.first)
  |> Enum.min()
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.chunk_while({nil, []}, parse_line, &{:cont, &1, nil})
|> Enum.to_list()
|> then(process_almanac)
|> IO.inspect(label: "Result")
