parse_input = fn stream ->
  stream
  |> Stream.with_index()
  |> Stream.flat_map(fn {line, y} ->
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {c, x} -> {{y, x}, c} end)
    |> Enum.reject(&(elem(&1, 1) == "."))
  end)
  |> Map.new()
end

get_main_loop = fn map ->
  start =
    map
    |> Map.filter(&(elem(&1, 1) == "S"))
    |> Map.keys()
    |> then(fn [{y, x}] ->
      [{y - 1, x}, {y + 1, x}, {y, x - 1}, {y, x + 1}]
      |> Enum.zip(["|7F", "|JL", "-LF", "-7J"])
      |> Enum.find(fn {pos, chars} ->
        chars
        |> String.contains?(Map.get(map, pos, "?"))
      end)
      |> elem(0)
      |> then(&[&1, {y, x}])
    end)

  Stream.cycle([true])
  |> Enum.reduce_while(start, fn _, [{y, x} = pos | tails] = acc ->
    map
    |> Map.get(pos)
    |> case do
      "|" -> [{y - 1, x}, {y + 1, x}]
      "J" -> [{y - 1, x}, {y, x - 1}]
      "L" -> [{y - 1, x}, {y, x + 1}]
      "-" -> [{y, x - 1}, {y, x + 1}]
      "7" -> [{y, x - 1}, {y + 1, x}]
      "F" -> [{y, x + 1}, {y + 1, x}]
      _ -> []
    end
    |> Enum.reject(&Enum.member?(tails, &1))
    |> case do
      [] -> {:halt, acc}
      [next] -> {:cont, [next | acc]}
    end
  end)
end

get_inner_side = fn map, loop ->
  loop_set = MapSet.new(loop)
  loop_len = length(loop)

  loop
  |> Enum.with_index()
  |> Enum.reduce({[], []}, fn {{y, x} = pos, index}, {left, right} ->
    map
    |> Map.get(pos)
    |> case do
      "|" -> {[{y, x + 1}], [{y, x - 1}]}
      "J" -> {[{y, x + 1}, {y + 1, x}], []}
      "L" -> {[], [{y, x - 1}, {y + 1, x}]}
      "-" -> {[{y - 1, x}], [{y + 1, x}]}
      "7" -> {[{y - 1, x}, {y, x + 1}], []}
      "F" -> {[], [{y - 1, x}, {y, x - 1}]}
      _ -> {[], []}
    end
    |> then(fn {l, r} ->
      prev = Enum.at(loop, index - 1)
      next = Enum.at(loop, rem(index + 1, loop_len))
      {l, r} = if prev < next, do: {l, r}, else: {r, l}
      {left |> Enum.concat(l), right |> Enum.concat(r)}
    end)
  end)
  |> then(fn {left, right} ->
    if Enum.min(left) < Enum.min(right), do: right, else: left
  end)
  |> Enum.uniq()
  |> Enum.reject(&MapSet.member?(loop_set, &1))
end

scan_area = fn loop, inner_side ->
  loop_set = MapSet.new(loop)

  inner_side
  |> Enum.reduce(%MapSet{}, fn item, set ->
    set = MapSet.put(set, item)

    Stream.cycle([true])
    |> Enum.reduce_while({[item], set}, fn _, {pos_list, set} ->
      if Enum.empty?(pos_list) do
        {:halt, set}
      else
        pos_list
        |> Enum.flat_map(fn {y, x} -> [{y - 1, x}, {y + 1, x}, {y, x - 1}, {y, x + 1}] end)
        |> Enum.reject(&MapSet.member?(loop_set, &1))
        |> Enum.reject(&MapSet.member?(set, &1))
        |> Enum.uniq()
        |> Enum.map(fn {y, x} = pos ->
          if y < 0 or x < 0 or x > 140 or y > 140 do
            IO.inspect(:standard_error, item, label: "Leaked from")
            exit(1)
          else
            pos
          end
        end)
        |> then(&{&1, MapSet.union(set, MapSet.new(&1))})
        |> then(&{:cont, &1})
      end
    end)
  end)
  |> MapSet.to_list()
end

_preview_loop = fn map, loop, inner_side ->
  file =
    __ENV__.file
    |> Path.dirname()
    |> Path.join("preview.txt")

  y = loop |> Enum.map(&elem(&1, 0)) |> Enum.max()
  x = loop |> Enum.map(&elem(&1, 1)) |> Enum.max()

  Enum.map(0..(y + 1), fn y ->
    Enum.map(
      0..(x + 1),
      fn x ->
        pos = {y, x}

        if Enum.member?(inner_side, pos) do
          "░"
        else
          case Enum.member?(loop, pos) && Map.get(map, pos) do
            "|" -> "║"
            "J" -> "╝"
            "L" -> "╚"
            "-" -> "═"
            "7" -> "╗"
            "F" -> "╔"
            "S" -> "▣"
            _ -> ~c" "
          end
        end
      end
    )
  end)
  |> Enum.join("\n")
  |> then(&File.write!(file, &1, [:write, :raw]))
end

process = fn map ->
  loop = get_main_loop.(map)
  inner_side = get_inner_side.(map, loop)

  # _preview_loop.(map, loop, inner_side)

  scan_area.(loop, inner_side)
  |> length()
end

__ENV__.file
|> Aoc2023.input_stream()
|> then(parse_input)
|> then(process)
|> IO.inspect(label: "Result")
