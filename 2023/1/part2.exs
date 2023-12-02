digits = %{
  "0" => 0,
  "1" => 1,
  "one" => 1,
  "2" => 2,
  "two" => 2,
  "3" => 3,
  "three" => 3,
  "4" => 4,
  "four" => 4,
  "5" => 5,
  "five" => 5,
  "6" => 6,
  "six" => 6,
  "7" => 7,
  "seven" => 7,
  "8" => 8,
  "eight" => 8,
  "9" => 9,
  "nine" => 9
}

read_document = fn doc ->
  :binary.matches(doc, Map.keys(digits)) |>
  (&[hd(&1), :lists.last(&1)]).() |>
  Enum.map(&digits[:binary.part(doc, &1)]) |>
  (fn [d1, d2] -> d1 * 10 + d2 end).()
end

input = Enum.at(System.argv(), 0) || "input.txt"

result = File.stream!(input) |>
  Stream.map(read_document) |>
  Stream.map(&IO.inspect/1) |>
  Enum.sum()

IO.inspect(result, label: "Result")
