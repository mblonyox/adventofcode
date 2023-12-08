defmodule BasicMath do
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: trunc(a * b / gcd(a, b))
end

defmodule Navigator do
  def parse_input(stream) do
    stream
    |> Enum.reduce({nil, %{}}, fn e, {nav, networks} = acc ->
      case Regex.scan(~r/[A-Z]+/, e) do
        [[n], [l], [r]] -> {nav, Map.put(networks, n, {l, r})}
        [[nav]] -> {nav, networks}
        _ -> acc
      end
    end)
  end

  def nav_until_z({nav, networks} = input, node, steps \\ 0) do
    reducer = fn lr, {node, steps} ->
      node
      |> then(&networks[&1])
      |> elem((lr == "R" && 1) || 0)
      |> then(fn node ->
        steps = steps + 1

        if node |> String.ends_with?("Z") do
          {:halt, steps}
        else
          {:cont, {node, steps}}
        end
      end)
    end

    nav
    |> String.split("", trim: true)
    |> Enum.reduce_while({node, steps}, reducer)
    |> case do
      {node, steps} -> nav_until_z(input, node, steps)
      steps -> steps
    end
  end

  def process({_nav, networks} = input) do
    networks
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(&nav_until_z(input, &1))
    |> Enum.reduce(1, &BasicMath.lcm/2)
  end
end

__ENV__.file
|> Aoc2023.input_stream()
|> Navigator.parse_input()
|> Navigator.process()
|> IO.inspect(label: "Result")
