defmodule Issues.CLITest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  doctest Issues.CLI

  import Issues.CLI

  test "Help is printed when -h or --help s given as an argument" do
    assert capture_io(fn ->
             main(["-h", "anything"])
           end) == "Usage: issues <user> <project> [count | 4]\n"
  end

  test "Issues header is printed correctly" do
    list = [
      %{"number" => 10, "created_at" => "2018-03-02T01:41:36Z", "title" => "Testing stuff"},
      %{"number" => 5, "created_at" => "2013-03-02T01:41:36Z", "title" => "Really Long Stuff"},
      %{"number" => 999, "created_at" => "2017-03-02T01:41:36Z", "title" => "O2"}
    ]

    assert capture_io(fn ->
             issues_header(list)
           end) == " #  | Created at           | Title             \n"
  end

  test "Issues row is printed correctly" do
    list = [
      %{"number" => 10, "created_at" => "2018-03-02T01:41:36Z", "title" => "Testing stuff"},
      %{"number" => 5, "created_at" => "2013-03-02T01:41:36Z", "title" => "Really Long Stuff"},
      %{"number" => 999, "created_at" => "2017-03-02T01:41:36Z", "title" => "O2"}
    ]

    assert capture_io(fn ->
             print_rows(list)
           end) == """
            10 | 2018-03-02T01:41:36Z | Testing stuff     
            5  | 2013-03-02T01:41:36Z | Really Long Stuff 
            999| 2017-03-02T01:41:36Z | O2                
           """
  end
end
