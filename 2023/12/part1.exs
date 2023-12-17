parse_input = fn line ->
  [record, nums] = String.split(line, ~r/\s+/, trim: true)
  {record, nums |> String.split(",") |> Enum.map(&String.to_integer/1)}
end

count_arrangements = fn {record, nums} ->
  nums_len = length(nums)

  Stream.cycle([true])
  |> Enum.reduce_while([record], fn _, list ->
    list
    |> Enum.any?(&String.contains?(&1, "?"))
    |> if do
      list
      |> Enum.flat_map(
        &[
          String.replace(&1, "?", ".", global: false),
          String.replace(&1, "?", "#", global: false)
        ]
      )
      |> Enum.filter(fn str ->
        occ =
          str
          |> String.split("?")
          |> Enum.at(0)
          |> String.split(".", trim: true)
          |> Enum.map(&String.length/1)

        occ_len = length(occ)

        occ
        |> Enum.with_index()
        |> Enum.all?(fn {n, i} ->
          if i >= nums_len do
            false
          else
            nums
            |> Enum.at(i)
            |> then(&(n == &1 or (i == occ_len - 1 and n < &1)))
          end
        end)
      end)
      |> then(&{:cont, &1})
    else
      {:halt, list}
    end
  end)
  |> Enum.count(fn str ->
    str
    |> String.split(".", trim: true)
    |> Enum.map(&String.length/1)
    |> case do
      ^nums -> true
      _ -> false
    end
  end)
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_input)
|> Stream.map(count_arrangements)
|> Enum.sum()
|> IO.inspect(label: "Result")
