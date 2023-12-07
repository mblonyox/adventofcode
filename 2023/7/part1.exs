parse_line = fn line ->
  [hand, bid] = line |> String.trim() |> String.split(" ")
  {hand, bid |> String.to_integer()}
end

strength = %{
  five_of_a_kind: 6,
  four_of_a_kind: 5,
  full_house: 4,
  three_of_a_kind: 3,
  two_pair: 2,
  one_pair: 1,
  high_card: 0
}

hand_type = fn hand ->
  hand
  |> String.split("", trim: true)
  |> Enum.reduce(%{}, fn c, acc ->
    acc
    |> Map.update(c, 1, &(&1 + 1))
  end)
  |> Map.values()
  |> Enum.sort(:desc)
  |> case do
    [2, 2, 1] ->
      :two_pair

    [3, 2] ->
      :full_house

    [n | _] ->
      case n do
        5 -> :five_of_a_kind
        4 -> :four_of_a_kind
        3 -> :three_of_a_kind
        2 -> :one_pair
        1 -> :high_card
      end
  end
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_line)
|> Enum.sort_by(
  &{strength[&1 |> elem(0) |> then(hand_type)],
   &1
   |> elem(0)
   |> String.replace("T", ":")
   |> String.replace("K", "k")
   |> String.replace("A", "Ã")}
)
|> Enum.with_index(&(elem(&1, 1) * (&2 + 1)))
|> Enum.sum()
|> IO.inspect(label: "Result")
