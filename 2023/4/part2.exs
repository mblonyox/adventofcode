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

process_card = fn {winning, owned}, {copies, total} ->
  current =
    copies
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
    |> Kernel.+(1)

  next_copies =
    copies
    |> Enum.map(fn {m, n} -> {m, n - 1} end)

  owned
  |> Enum.count(&Enum.member?(winning, &1))
  |> then(&[{current, &1} | next_copies])
  |> Enum.filter(&(elem(&1, 1) > 0))
  |> then(&{&1, total + current})
end

Aoc2023.input_stream(4)
|> Stream.map(parse_line)
|> Enum.reduce({[], 0}, process_card)
|> then(&elem(&1, 1))
|> IO.inspect(label: "Result")
