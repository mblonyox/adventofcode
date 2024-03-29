parse_line = fn doc ->
  String.replace(doc, ~r/[^\d]/, "")
  |> then(&(String.first(&1) <> String.last(&1)))
  |> String.to_integer()
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_line)
|> Enum.sum()
|> IO.inspect(label: "Result")
