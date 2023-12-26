__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(&String.to_charlist/1)
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
|> Enum.map(fn list ->
  list
  |> List.to_string()
  |> String.split("#")
  |> Enum.map(fn str ->
    str |> String.to_charlist() |> Enum.sort(:desc) |> List.to_string()
  end)
  |> Enum.join("#")
  |> String.to_charlist()
end)
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
|> Enum.reverse()
|> Enum.with_index(1)
|> Enum.map(fn {list, load} ->
  list
  |> Enum.count(&(?O == &1))
  |> Kernel.*(load)
end)
|> Enum.sum()
|> IO.inspect(label: "Result")
