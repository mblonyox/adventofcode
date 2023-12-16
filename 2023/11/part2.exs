expansion = 1000000

parse_input = fn stream ->
  stream
  |> Stream.with_index()
  |> Stream.flat_map(fn {line, y} ->
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {c, x} -> {{y, x}, c} end)
  end)
  |> Enum.filter(&(elem(&1, 1) == "#"))
  |> Enum.map(&elem(&1, 0))
end

pairs = fn list ->
  xs =
    list
    |> Enum.map(&elem(&1, 0))
    |> Enum.uniq()

  ys =
    list
    |> Enum.map(&elem(&1, 1))
    |> Enum.uniq()

  distance = fn {y1, x1}, {y2, x2} ->
    [y1, y2] = Enum.sort([y1, y2])
    [x1, x2] = Enum.sort([x1, x2])

    dy =
      xs
      |> Enum.count(&(y1 < &1 && y2 > &1))
      |> then(&if y2 == y1, do: 0, else: &1 + 1 + (y2 - y1 - 1 - &1) * expansion)

    dx =
      ys
      |> Enum.count(&(x1 < &1 && x2 > &1))
      |> then(&if x2 == x1, do: 0, else: &1 + 1 + (x2 - x1 - 1 - &1) * expansion)

    dy + dx
  end

  list
  |> Enum.flat_map(fn item1 ->
    list
    |> Enum.reject(&(&1 == item1))
    |> Enum.map(fn item2 ->
      key = if item1 <= item2, do: {item1, item2}, else: {item2, item1}
      value = distance.(item1, item2)
      {key, value}
    end)
  end)
  |> Map.new()
end

__ENV__.file
|> Aoc2023.input_stream()
|> then(parse_input)
|> then(pairs)
|> Map.values()
|> Enum.sum()
|> IO.inspect(label: "Result")
