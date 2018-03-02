defmodule Issues.CLI do
  @default_count 4

  def process(:help) do
    IO.puts("Usage: issues <user> <project> [count | #{@default_count}]")
    # unless Mix.env == :test do
    System.halt(0)
    # end
  end

  def process({user, project, count}) do
    Issues.Github.fetch(user, project)
    |> decode_response
    |> sort_in_ascending_order
    |> Enum.take(count)
    |> pretty_print
  end

  def pretty_print(list) do
    issues_header(list)
    print_rows(list)
  end

  def print_rows(list) do
    num_col_w = column_width(list, "number")
    created_at_col_w = column_width(list, "created_at")
    title_col_w = column_width(list, "title")

    Enum.each(list, fn mp ->
      num_r = String.pad_trailing(Kernel.to_string(Map.get(mp, "number")), num_col_w)
      created_at_r = String.pad_trailing(Map.get(mp, "created_at"), created_at_col_w)
      title_r = String.pad_trailing(Map.get(mp, "title"), title_col_w)
      IO.puts(" #{num_r}| #{created_at_r} | #{title_r} ")
    end)
  end

  @doc ~S"""
  Returns the column width of `column` in a `list` os maps based on the maximum 
  String.length of values with key `column`

  ## Examples

      iex> Issues.CLI.column_width([%{"number" => 451}, %{"number" => 3}, %{"number" => 9999}], "number")
      4

      iex> Issues.CLI.column_width([%{"title" => "Testing stuff"}, %{"title" => "Really Long Stuff"}, %{"title" => "O2"}], "title")
      17

  """
  def column_width(list, column) do
    list
    |> Enum.map(fn x -> Map.get(x, column) end)
    |> Enum.map(&Kernel.to_string(&1))
    |> Enum.map(&String.length(&1))
    |> Enum.max()
  end

  def issues_header(list) do
    num_col_w = column_width(list, "number")
    created_at_col_w = column_width(list, "created_at")
    title_col_w = column_width(list, "title")

    num_h = String.pad_trailing("#", num_col_w)
    created_at_h = String.pad_trailing("Created at", created_at_col_w)
    title_h = String.pad_trailing("Title", title_col_w)

    IO.puts(" #{num_h}| #{created_at_h} | #{title_h} ")
  end

  @doc ~S"""
  Sorts a list of maps based on created_at key

  ## Example

      iex> Issues.CLI.sort_in_ascending_order([%{created_at: "2018-03-02T01:41:36Z"},%{created_at: "2018-02-02T01:41:36Z"},%{created_at: "2018-05-02T01:41:36Z"}])
      [
        %{created_at: "2018-02-02T01:41:36Z"},
        %{created_at: "2018-03-02T01:41:36Z"},
        %{created_at: "2018-05-02T01:41:36Z"}
      ]
  """
  def sort_in_ascending_order(list_of_issues) do
    Enum.sort(list_of_issues, fn is1, is2 ->
      Map.get(is1, :created_at) <= Map.get(is2, :created_at)
    end)
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

    # remember to uncomment this before going into production... need to know
    # how to have this and tests together...
    # if Mix.env == :test do
    #   message
    # else
    IO.puts(message)
    System.halt(2)
    # end
  end

  def main(argv) do
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
