input = Enum.at(System.argv(), 0) || "input.txt"

digits = %{
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

pattern = Map.keys(digits)
r_pattern = Enum.map(pattern, &String.reverse/1)

parse_line = fn line ->
  r_line = String.reverse(line)

  {:binary.match(line, pattern)
   |> then(&:binary.part(line, &1))
   |> then(&digits[&1]),
   :binary.match(r_line, r_pattern)
   |> then(&:binary.part(r_line, &1))
   |> then(&digits[String.reverse(&1)])}
  |> then(fn {d1, d2} -> d1 * 10 + d2 end)
end

result =
  File.stream!(input)
  |> Stream.map(parse_line)
  # |> Stream.map(&IO.inspect/1)
  |> Enum.sum()

IO.inspect(result, label: "Result")
