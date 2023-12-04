parse_numbers = fn numbers ->
  numbers
  |> String.split(~r/\s+/, trim: true)
  |> Enum.map(&String.to_integer/1)
end

parse_line = fn line ->
  [card_id, winning_numbers, owned_numbers] =
    line
    |> String.trim()
    |> String.split([":", "|"])

  %{
    id:
      card_id
      |> String.split(~r/\s+/)
      |> List.last()
      |> String.to_integer(),
    winning: parse_numbers.(winning_numbers),
    owned: parse_numbers.(owned_numbers)
  }
end

process_card = fn %{winning: winning, owned: owned} ->
  owned
  |> Enum.count(&Enum.member?(winning, &1))
  |> case do
    0 -> 0
    exponent -> Integer.pow(2, exponent - 1)
  end
end

Aoc2023.input_stream(4)
|> Stream.map(parse_line)
|> Stream.map(process_card)
|> Enum.sum()
|> IO.inspect(label: "Result")
