defmodule Issues.CLITest do
  use ExUnit.Case, async: true
  doctest Issues.CLI

  import Issues.CLI, only: [parse_args: 1]
end