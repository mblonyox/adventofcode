input = Enum.at(System.argv(), 0) || "input.txt"

parse_line = fn doc ->
  String.replace(doc, ~r/[^\d]/, "")
  |> then(&(String.first(&1) <> String.last(&1)))
  |> String.to_integer()
end

result =
  File.stream!(input)
  |> Stream.map(parse_line)
  # |> Stream.map(&IO.inspect/1)
  |> Enum.sum()

IO.inspect(result, label: "Result")
