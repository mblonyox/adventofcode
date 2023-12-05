parse_numbers = fn numbers ->
  numbers
  |> String.split(~r/\s+/, trim: true)
  |> Enum.map(&String.to_integer/1)
end

parse_line = fn line, {s, l} = acc ->
  case line |> String.trim() |> String.split([":", " map:"]) do
    [""] -> {:cont, acc, {nil, []}}
    ["seeds", n] -> {:cont, {"seeds", parse_numbers.(n)}}
    [s, ""] -> {:cont, {s, []}}
    [n] -> parse_numbers.(n) |> List.to_tuple() |> then(&{:cont, {s, [&1 | l]}})
  end
end

process_almanac = fn [{"seeds", seeds} | maps] = almanac ->
  seeds
  |> Enum.map(fn n ->
    maps
    |> fn {_, l} -> nil end
  end)
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.chunk_while({nil, []}, parse_line, &{:cont, &1})
|> Enum.to_list()
|> IO.inspect(label: "Result")
