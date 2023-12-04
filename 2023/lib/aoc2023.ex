defmodule Aoc2023 do
  @moduledoc """
  Documentation for `Aoc2023`.
  """

  def input_stream(day) do
    System.argv()
    |> Enum.at(0)
    |> Kernel.||("./#{day}/input.txt")
    |> then(&(File.exists?(&1) && File.stream!(&1)))
    |> Kernel.||(get_input(day))
  end

  defp get_session_cookie do
    System.get_env("AOC_SESSION_COOKIE")
    |> Kernel.||(IO.gets("Please provide adventofcode.com session cookie value:\n"))
  end

  defp get_input(day) do
    Req.get!("https://adventofcode.com/2023/day/#{day}/input",
      headers: %{cookie: "session=" <> get_session_cookie()}
    ).body
    |> tap(&File.write!("./#{day}/input.txt", &1))
    |> StringIO.open()
    |> elem(1)
    |> IO.stream(:line)
  end
end
