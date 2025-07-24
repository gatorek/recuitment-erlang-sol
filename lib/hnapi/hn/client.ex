defmodule Hnapi.Hn.Client do
  @moduledoc """
  A client for the Hacker News API.

  It uses Req for HTTP requests.
  """

  @type id :: non_neg_integer()
  @type stories :: %{id => map()}
  @type limit :: non_neg_integer()

  @base_url "https://hacker-news.firebaseio.com/v0"
  @default_limit 50

  @spec get_top_stories(limit) :: stories
  def get_top_stories(limit \\ @default_limit) do
    story_ids =
      "#{@base_url}/topstories.json"
      |> get_json()
      |> Enum.take(limit)

    # TODO A naive implementation processing each story one by one; might be optimized
    Enum.map(story_ids, fn story_id ->
      "#{@base_url}/item/#{story_id}.json"
      |> get_json()
      |> then(&{&1["id"], &1})
    end)
    |> Enum.into(%{})
  end

  defp get_json(url) do
    url
    |> Req.get!(Application.get_env(:hnapi, :hn_req_opts, []))
    |> Map.get(:body)
  end
end
