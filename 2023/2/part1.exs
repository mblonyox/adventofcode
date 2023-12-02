bag = %{"red" => 12, "green" => 13, "blue" => 14}

parse_info = fn info ->
  String.split(info, ", ", trim: true)
    |> Enum.reduce(%{},
      fn (cube, acc) ->
        [num, color] = String.split(cube, " ", trim: true)
        Map.put(acc, color, String.to_integer(num))
      end)
end

parse_record = fn line ->
  [game_id, infos] = String.trim(line)
    |> String.split(": ", trim: true)
  %{
    id: String.slice(game_id, 5..-1) |> String.to_integer,
    infos: String.split(infos, "; ", trim: true) |> Enum.map(parse_info)
  }
end

check_possibility = fn %{infos: infos} ->
  Enum.flat_map(infos, &Map.to_list/1)
    |> Enum.find_value(fn {color, num} -> num > bag[color] end)
    |> Kernel.!
end

input = Enum.at(System.argv(), 0) || "input.txt"

result = File.stream!(input)
  |> Stream.map(parse_record)
  |> Stream.filter(check_possibility)
  |> Stream.map(&(Map.fetch!(&1, :id)))
  # |> Stream.map(&IO.inspect/1)
  |> Enum.sum()

IO.inspect(result, label: "Result")
