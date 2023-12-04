parse_numbers = fn numbers ->
  numbers
  |> String.split(~r/\s+/, trim: true)
  |> Enum.map(&String.to_integer/1)
end

parse_line = fn line ->
  [_, winning, owned] =
    line
    |> String.trim()
    |> String.split([":", "|"])

  {
    parse_numbers.(winning),
    parse_numbers.(owned)
  }
end

process_card = fn {winning, owned}, {copies, total} ->
  owned
  |> Enum.count(&Enum.member?(winning, &1))
  |> case do
    0 -> 0
    exponent -> Integer.pow(2, exponent - 1)
  end
end

Aoc2023.input_stream(4)
|> Stream.map(parse_line)
|> Enum.reduce({[], 0}, process_card)
|> IO.inspect(label: "Result")
