list =
  __ENV__.file
  |> Aoc2023.input_stream()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_charlist/1)
  |> Enum.to_list()

get_point = fn {y, x} ->
  with true <- x >= 0,
       true <- y >= 0,
       list = [_ | _] <- Enum.at(list, y) do
    Enum.at(list, x)
  else
    _ -> nil
  end
end

energize = fn start ->
  Stream.cycle([true])
  |> Enum.reduce_while({[start], MapSet.new([start])}, fn _, {beams, paths} ->
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
  |> MapSet.to_list()
  |> Enum.map(fn {y, x, _} -> {y, x} end)
  |> Enum.uniq()
  |> Enum.count()
end

max_y = length(list) - 1
max_x = length(List.first(list)) - 1

0..max_x
|> Enum.flat_map(&[{0, &1, :down}, {max_y, &1, :up}])
|> Enum.concat(0..max_y |> Enum.flat_map(&[{&1, 0, :right}, {&1, max_x, :left}]))
|> Enum.map(energize)
|> Enum.max()
|> IO.inspect(label: "Result")
