read_document = fn doc ->
  doc |>
    String.replace(~r/[^\d]/, "") |>
    (&(String.first(&1) <> String.last(&1))).() |>
    String.to_integer()
end

input = Enum.at(System.argv(), 0) || "input.txt"

result = File.stream!(input) |>
  Stream.map(read_document) |>
  Stream.map(&IO.inspect/1) |>
  Enum.sum()

IO.inspect(result, label: "Result")
