defmodule Issues.Github do
  @user_agent [{"User-agent", "Elixir donatoaz@gmail.com"}]

  @doc ~S"""
  GETs the URL for a given user and project and processes the response

  ## Examples

      iex> Issues.Github.fetch("donatoaz","metaprogramming-ruby")
      {:ok, []}

  """
  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  @doc ~S"""
  Returns the URL for a given user and project

  ## Examples

      iex> Issues.Github.issues_url("donatoaz","metaprogramming-ruby")
      "https://api.github.com/repos/donatoaz/metaprogramming-ruby/issues"

  """
  def issues_url(user, project), do: "https://api.github.com/repos/#{user}/#{project}/issues"

  @doc ~S"""
  Handles the response in a success or error case

  ## Examples

      iex> Issues.Github.handle_response({:ok, %{status_code: 200, body: ~s({"name": "Devin Torres", "age": 27}) }})
      {:ok, %{"name" => "Devin Torres", "age" => 27}}

      iex> Issues.Github.handle_response({:anything, %{status_code: :anything, body: ~s({"name": "Devin Torres", "age": 27})  }})
      {:error, %{"name" => "Devin Torres", "age" => 27}}

  """
  def handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  def handle_response({_, %{status_code: _, body: body}}) do
    {:error, Poison.Parser.parse!(body)}
  end
end
