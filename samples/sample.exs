# Elixir script for file processing

defmodule FileProcessor do
  def read_lines(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end

  def count_words(text) do
    text
    |> String.split(~r/\W+/)
    |> Enum.reject(&(&1 == ""))
    |> length()
  end
end

path = "sample.exs"
lines = FileProcessor.read_lines(path)

IO.inspect(lines)
IO.puts("Word count: #{FileProcessor.count_words(Enum.join(lines))}")
