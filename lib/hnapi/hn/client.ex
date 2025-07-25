defmodule Hnapi.Hn.Client do
  @moduledoc """
  A client for the Hacker News API.

  It uses Req for HTTP requests.
  """

  @type id :: non_neg_integer()
  @type story :: map()
  @type stories :: [story]
  @type limit :: non_neg_integer()
  @type json :: map() | list()
  @type url :: String.t()

  @base_url "https://hacker-news.firebaseio.com/v0"
  @default_limit 50

  @spec get_top_stories(limit) :: stories
  def get_top_stories(limit \\ @default_limit) do
    story_ids =
      fetch_top_stories()
      |> Enum.take(limit)

    story_ids
    |> Task.async_stream(&fetch_story/1)
    |> Enum.map(fn {:ok, result} -> result end)
  end

  # Function is not used anywhere, but it's public for the testability reson
  @spec get_json(url) :: json
  def get_json(url) do
    url
    |> Req.get!(Application.get_env(:hnapi, :hn_req_opts, []))
    |> Map.get(:body)
  end

  defp fetch_story(story_id) do
    get_json("#{@base_url}/item/#{story_id}.json")
  end

  defp fetch_top_stories() do
    get_json("#{@base_url}/topstories.json")
  end
end
