parse_numbers = fn numbers ->
  numbers
  |> String.split(~r/\s+/, trim: true)
  |> Enum.map(&String.to_integer/1)
end

parse_line = fn line ->
  line
  |> String.trim()
  |> String.split([":", "|"])
  |> tl()
  |> Enum.map(parse_numbers)
  |> List.to_tuple()
end

process_card = fn {winning, owned} ->
  owned
  |> Enum.count(&Enum.member?(winning, &1))
  |> case do
    0 -> 0
    exponent -> Integer.pow(2, exponent - 1)
  end
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_line)
|> Stream.map(process_card)
|> Enum.sum()
|> IO.inspect(label: "Result")
