defmodule Aoc2023 do
  @moduledoc """
  Documentation for `Aoc2023`.
  """

  def input_stream(file) do
    System.argv()
    |> Enum.at(0)
    |> Kernel.||(default_input_file(file))
    |> then(&(File.exists?(&1) && File.stream!(&1)))
    |> Kernel.||(get_input(file))
  end

  defp default_input_file(file) do
    file
    |> Path.dirname()
    |> Path.join("input.txt")
  end

  defp get_session_cookie do
    System.get_env("AOC_SESSION_COOKIE")
    |> Kernel.||(IO.gets("Please provide adventofcode.com session cookie value:\n"))
  end

  defp get_input(file) do
    file
    |> Path.dirname()
    |> Path.basename()
    |> then(
      &Req.get!("https://adventofcode.com/2023/day/#{&1}/input",
        headers: %{cookie: "session=" <> get_session_cookie()}
      ).body
    )
    |> tap(&File.write!(default_input_file(file), &1))
    |> StringIO.open()
    |> elem(1)
    |> IO.stream(:line)
  end
end
