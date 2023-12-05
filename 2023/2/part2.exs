parse_info = fn info ->
  String.split(info, ", ", trim: true)
  |> Enum.reduce(
    %{},
    fn cube, acc ->
      [num, color] = String.split(cube, " ", trim: true)
      Map.put(acc, color, String.to_integer(num))
    end
  )
end

parse_record = fn line ->
  [game_id, infos] =
    String.trim(line)
    |> String.split(": ", trim: true)

  %{
    id: String.slice(game_id, 5..-1) |> String.to_integer(),
    infos: String.split(infos, "; ", trim: true) |> Enum.map(parse_info)
  }
end

count_power = fn %{infos: infos} ->
  min_cube_color = fn color ->
    Enum.max_by(infos, &(&1[color] || 0))
    |> Map.fetch(color)
    |> case do
      {:ok, value} -> value
      :error -> 1
    end
  end

  Enum.map(["red", "green", "blue"], min_cube_color)
  |> Enum.product()
end

__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(parse_record)
|> Stream.map(count_power)
|> Enum.sum()
|> IO.inspect(label: "Result")
