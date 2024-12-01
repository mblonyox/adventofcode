__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(fn line ->
  line
  |> String.trim()
  |> String.split("", trim: true)
  |> Enum.map(&String.to_integer/1)
end)
|> Enum.to_list()
|> then(fn list ->
  get_point = fn {y, x} ->
    with true <- x >= 0,
         true <- y >= 0,
         list = [_ | _] <- Enum.at(list, y) do
      Enum.at(list, x)
    else
      _ -> nil
    end
  end

end)
|> IO.inspect(label: "Result")
