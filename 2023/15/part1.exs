hash = fn str ->
  str
  |> String.to_charlist()
  |> Enum.reduce(0, &rem((&1 + &2) * 17, 256))
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.take(1)
|> Enum.at(0)
|> String.trim()
|> String.split(",", trim: true)
|> Enum.map(hash)
|> Enum.sum()
|> IO.inspect(label: "Result")
