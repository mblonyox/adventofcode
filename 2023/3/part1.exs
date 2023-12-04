parse_line = fn {line, index} ->
  Regex.scan(~r/\d+|[^\d\.]/, line, return: :index)
  |> Enum.map(&Kernel.hd/1)
  |> Enum.map(fn {start, length} ->
    text = String.slice(line, start, length)

    Integer.parse(text)
    |> case do
      {number, _remainder} -> {number, index, start, length}
      :error -> {text, index, start, length}
    end
  end)
end

process_numbers = fn %{numbers: numbers, symbols: symbols} ->
  Enum.filter(numbers, fn {_, number_index, number_start, length} ->
    Enum.find_value(symbols, fn {_, symbol_index, symbol_start, _} ->
      Enum.member?((number_index - 1)..(number_index + 1), symbol_index) &&
        Enum.member?((number_start - 1)..(number_start + length), symbol_start)
    end)
  end)
  |> Enum.map(&elem(&1, 0))
  |> Enum.sum()
end

Aoc2023.input_stream(3)
|> Stream.map(&String.trim/1)
|> Stream.with_index()
|> Stream.flat_map(parse_line)
|> Enum.group_by(&((is_integer(elem(&1, 0)) && :numbers) || :symbols))
|> then(process_numbers)
|> IO.inspect(label: "Result")
