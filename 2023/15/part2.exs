hash = fn str ->
  str
  |> String.to_charlist()
  |> Enum.reduce(0, &rem((&1 + &2) * 17, 256))
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.take(1)
|> Enum.at(0)
|> String.trim()
|> String.split(",", trim: true)
|> Enum.reduce(List.duplicate([], 256), fn str, acc ->
  [key | tail] = String.split(str, ["-", "="], trim: true)
  index = hash.(key)

  list = Enum.at(acc, index)

  list =
    case tail do
      [] ->
        Enum.reject(list, fn {k, _} -> k == key end)

      [value] ->
        Enum.find_index(list, fn {k, _} -> k == key end)
        |> case do
          nil -> list ++ [{key, String.to_integer(value)}]
          i -> List.replace_at(list, i, {key, String.to_integer(value)})
        end
    end

  List.replace_at(acc, index, list)
end)
|> Enum.with_index(1)
|> Enum.flat_map(fn {list, i} ->
  list
  |> Enum.with_index(1)
  |> Enum.map(fn {{_, value}, j} -> i * j * value end)
end)
|> Enum.sum()
|> IO.inspect(label: "Result")
