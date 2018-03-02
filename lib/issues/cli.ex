defmodule Issues.CLI do
  @default_count 4

  @doc ~S"""
  Just making sure help is working, for now

  ## Examples

      iex> Issues.CLI.run(["-h"])
      "Usage: issues <user> <project> [count | 4]"

      iex> Issues.CLI.run(["--help", "anything"])
      "Usage: issues <user> <project> [count | 4]"

  """
  def process(:help) do
    "Usage: issues <user> <project> [count | #{@default_count}]"
    # System.halt(0)
  end

  def process({user, project, _count}) do
    Issues.Github.fetch(user, project)
    |> decode_response
  end

  def decode_response({:ok, body}), do: body

  @doc ~S"""
  In case of error, extract the message from the response body

  ## Example

      iex> Issues.CLI.decode_response({:error, [message: "Error message"]})
      "Error message"
  """
  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, :message, 0)
    message
  end

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc ~S"""
  Parses command line arguments into first step of program

  ## Examples

      iex> Issues.CLI.parse_args(["-h"])
      :help

      iex> Issues.CLI.parse_args(["--help", "anything"])
      :help

      iex> Issues.CLI.parse_args(["user", "project", "88"])
      {"user", "project", 88}

      iex> Issues.CLI.parse_args(["user", "project"])
      {"user", "project", 4}

  """

  def parse_args(argv) do
    parse =
      OptionParser.parse(
        argv,
        switches: [help: :boolean],
        aliase: [h: :help]
      )

    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer(count)}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end
end
