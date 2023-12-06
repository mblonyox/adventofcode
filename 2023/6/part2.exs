parse_line = fn line ->
  [label, numbers] = String.split(line, ":", trim: true)
  {label, numbers |> String.replace(~r/\s+/, "") |> String.to_integer()}
end

solve_quadratic = fn a, b, c ->
  b24ac = b |> :math.pow(2) |> Kernel.-(4 * a * c) |> :math.sqrt()
  [(-b24ac - b) / (2 * a), (b24ac - b) / (2 * a)]
end

process_races = fn %{"Time" => time, "Distance" => distance} ->
  [low, high] =
    solve_quadratic.(-1, time, -distance)
    |> Enum.sort()
    |> Enum.map(&trunc/1)

  high - low
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_line)
|> Map.new()
|> then(process_races)
|> IO.inspect(label: "Result")
