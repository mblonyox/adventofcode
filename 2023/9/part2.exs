parse_input = fn line ->
  line
  |> String.split(~r/\s+/, trim: true)
  |> Enum.map(&String.to_integer/1)
end

predict_next_value = fn numbers ->
  numbers
  |> Enum.reverse()
  |> Enum.reduce([], fn n, acc ->
    acc
    |> Enum.map_reduce(n, fn h, n -> {n, n - h} end)
    |> then(fn {h, n} -> Enum.concat(h, [n]) end)
  end)
  |> Enum.sum()
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_input)
|> Stream.map(predict_next_value)
|> Enum.sum()
|> IO.inspect(label: "Result")
