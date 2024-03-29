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
  seeds
  |> Enum.map(fn num ->
    maps
    |> Enum.reduce(num, fn {_, list}, acc ->
      list
      |> Enum.find_value(acc, fn {src, delta} ->
        if Enum.member?(src, acc), do: acc + delta, else: nil
      end)
    end)
  end)
  |> Enum.min()
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.chunk_while({nil, []}, parse_line, &{:cont, &1, nil})
|> Enum.to_list()
|> then(process_almanac)
|> IO.inspect(label: "Result")
