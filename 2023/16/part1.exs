__ENV__.file
|> Aoc2023.input_stream()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_charlist/1)
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

  Stream.cycle([true])
  |> Enum.reduce_while({[{0, 0, :right}], MapSet.new([{0, 0, :right}])}, fn _, {beams, paths} ->
    if Enum.empty?(beams) do
      {:halt, paths}
    else
      beams =
        beams
        |> Enum.flat_map(fn {y, x, dir} ->
          get_point.({y, x})
          |> case do
            ?| when dir == :left or dir == :right ->
              [{y - 1, x, :up}, {y + 1, x, :down}]

            ?- when dir == :up or dir == :down ->
              [{y, x - 1, :left}, {y, x + 1, :right}]

            ?/ ->
              case dir do
                :up -> [{y, x + 1, :right}]
                :down -> [{y, x - 1, :left}]
                :left -> [{y + 1, x, :down}]
                :right -> [{y - 1, x, :up}]
              end

            ?\\ ->
              case dir do
                :up -> [{y, x - 1, :left}]
                :down -> [{y, x + 1, :right}]
                :left -> [{y - 1, x, :up}]
                :right -> [{y + 1, x, :down}]
              end

            nil ->
              []

            _ ->
              case dir do
                :up -> [{y - 1, x, :up}]
                :down -> [{y + 1, x, :down}]
                :left -> [{y, x - 1, :left}]
                :right -> [{y, x + 1, :right}]
              end
          end
        end)
        |> Enum.reject(&MapSet.member?(paths, &1))

      paths =
        beams
        |> Enum.filter(fn {y, x, _} -> get_point.({y, x}) end)
        |> MapSet.new()
        |> MapSet.union(paths)

      {:cont, {beams, paths}}
    end
  end)
end)
|> MapSet.to_list()
|> Enum.map(fn {y, x, _} -> {y, x} end)
|> Enum.uniq()
|> Enum.count()
|> IO.inspect(label: "Result")
