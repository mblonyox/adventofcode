transpose = fn tuple, fun ->
  tuple
  |> Tuple.to_list()
  |> Enum.map(&Tuple.to_list/1)
  |> Enum.zip()
  |> Enum.map(fun)
  |> Enum.map(&Tuple.to_list/1)
  |> Enum.zip()
  |> List.to_tuple()
end

no_transpose = fn tuple, fun ->
  tuple
  |> Tuple.to_list()
  |> Enum.map(fun)
  |> List.to_tuple()
end

sort = fn tuple, asc_desc ->
  tuple
  |> Tuple.to_list()
  |> List.to_string()
  |> String.split("#")
  |> Enum.map(fn str ->
    str
    |> String.to_charlist()
    |> Enum.sort(asc_desc)
    |> List.to_string()
  end)
  |> Enum.join("#")
  |> String.to_charlist()
  |> List.to_tuple()
end

tilt = fn tuple, dir ->
  case dir do
    :north -> transpose.(tuple, &sort.(&1, :desc))
    :west -> no_transpose.(tuple, &sort.(&1, :desc))
    :south -> transpose.(tuple, &sort.(&1, :asc))
    :east -> no_transpose.(tuple, &sort.(&1, :asc))
  end
end

spin = fn tuple ->
  [:north, :west, :south, :east]
  |> Enum.reduce(tuple, fn dir, tuple ->
    tilt.(tuple, dir)
  end)
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_charlist/1)
|> Stream.map(&List.to_tuple/1)
|> Enum.to_list()
|> List.to_tuple()
|> then(fn tuple ->
  1..1_000_000_000
  |> Enum.reduce_while([tuple], fn n, list ->
    list
    |> List.last()
    |> then(spin)
    |> then(fn tuple ->
      Enum.find_index(list, &(tuple == &1))
      |> case do
        nil -> {:cont, list ++ [tuple]}
        i -> {:halt, Enum.at(list, rem(1_000_000_000 - n, n - i) + i)}
      end
    end)
  end)
end)
|> Tuple.to_list()
|> Enum.reverse()
|> Enum.with_index(1)
|> Enum.map(fn {tuple, load} ->
  tuple
  |> Tuple.to_list()
  |> Enum.count(&(?O == &1))
  |> Kernel.*(load)
end)
|> Enum.sum()
|> IO.inspect(label: "Result")
