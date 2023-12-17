# Hint: https://github.com/maneatingape/advent-of-code-rust/blob/main/src/year2023/day12.rs

parse_input = fn line ->
  [record, nums] = String.split(line, ~r/\s+/, trim: true)
  {record, nums |> String.split(",") |> Enum.map(&String.to_integer/1)}
end

unfold_input = fn {record, nums} ->
  {Stream.repeatedly(fn -> record end)
   |> Stream.take(5)
   |> Enum.join("?"),
   Stream.repeatedly(fn -> nums end)
   |> Stream.take(5)
   |> Enum.flat_map(& &1)}
end

count_arrangements = fn {record, springs} ->
  free = String.length(record) - Enum.sum(springs) - length(springs) + 1

  springs
  |> Enum.reduce({0, %{}, 0}, fn size, {start, prev_map, _prev_sum} ->
    start..(start + free)
    |> Enum.reduce(
      {0, %{}},
      fn i, {sum, map} ->
        prev = if start == 0, do: 1, else: Map.get(prev_map, i - 1, 0)

        sum =
          cond do
            record
            |> String.at(i + size)
            |> Kernel.==("#") ->
              0

            record
            |> String.slice(0..(i - 1))
            |> String.contains?("#")
            |> Kernel.and(start == 0)
            |> Kernel.and(i > 0) ->
              sum

            record
            |> String.at(i - 1)
            |> Kernel.==("#")
            |> Kernel.and(start > 0) ->
              sum

            record
            |> String.slice(i, size)
            |> String.contains?(".") ->
              sum

            record
            |> String.slice(i, size)
            |> String.length()
            |> Kernel.!=(size) ->
              sum

            true ->
              sum + prev
          end

        map = Map.put(map, i + size, sum)
        {sum, map}
      end
    )
    |> then(fn {sum, map} -> {start + size + 1, map, sum} end)
  end)
  |> elem(2)
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_input)
|> Stream.map(unfold_input)
|> Stream.map(count_arrangements)
|> Enum.sum()
|> IO.inspect(label: "Result")
