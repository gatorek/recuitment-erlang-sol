defmodule Hnapi.Hn.Client do
  @moduledoc """
  A client for the Hacker News API.

  It uses Req for HTTP requests.
  """

  @type id :: non_neg_integer()
  @type stories :: %{id => map()}

  @base_url "https://hacker-news.firebaseio.com/v0"

  @spec get_top_stories() :: stories
  def get_top_stories do
    story_ids = get_json("#{@base_url}/topstories.json")

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
    |> Req.get!(Application.get_env(:hn_client, :hn_req_opts, []))
    |> Map.get(:body)
  end
end
