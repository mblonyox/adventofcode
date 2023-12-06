parse_line = fn line ->
  [label | numbers] = String.split(line, ~r/:?\s+/, trim: true)
  {label, numbers |> Enum.map(&String.to_integer/1)}
end

process_races = fn %{"Time" => times, "Distance" => distances} ->
  times
  |> Enum.zip(distances)
  |> Enum.map(fn {time, distance} ->
    Range.new(1, time - 1)
    |> Enum.map(fn t -> t * (time - t) end)
    |> Enum.count(fn t -> t >= distance end)
  end)
  |> Enum.product()
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_line)
|> Map.new()
|> then(process_races)
|> IO.inspect(label: "Result")
