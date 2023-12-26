parse_input = fn stream ->
  stream
  |> Stream.chunk_while(
    [],
    fn line, acc ->
      if line == "\n" do
        {:cont, acc, []}
      else
        {:cont, Enum.concat(acc, [line |> String.trim() |> String.to_charlist()])}
      end
    end,
    &{:cont, &1, nil}
  )
end

rotate = fn list ->
  list
  |> Enum.at(0)
  |> Enum.with_index()
  |> Enum.map(fn {_, i} ->
    list |> Enum.map(&Enum.at(&1, i))
  end)
end

find_reflection = fn list ->
  finish = length(list) - 1

  1..finish
  |> Enum.find(0, fn i ->
    list
    |> Enum.split(i)
    |> then(fn {left, right} ->
      size = Enum.min([length(left), length(right)])
      left = left |> Enum.slice(-size..-1)
      right = right |> Enum.slice(0..(size - 1)) |> Enum.reverse()
      left == right
    end)
  end)
end

process = fn list ->
  find_reflection.(list) * 100 +
    find_reflection.(rotate.(list))
end

__ENV__.file
|> Aoc2023.input_stream()
|> then(parse_input)
|> Stream.map(process)
|> Enum.sum()
|> IO.inspect(label: "Result")
