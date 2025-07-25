defmodule Hnapi.Hn.Client do
  @moduledoc """
  A client for the Hacker News API.

  It uses Req for HTTP requests.
  """

  @type id :: non_neg_integer()
  @type story :: map()
  @type limit :: non_neg_integer()
  @type url :: String.t()

  @base_url "https://hacker-news.firebaseio.com/v0"
  @default_limit 50
  # Task timeout for getting stories. Includes Req retries.
  @task_timeout 10_000

  @spec get_top_stories(limit) :: {:ok, [story]} | :error
  def get_top_stories(limit \\ @default_limit) do
    case get_top_stories_ids() do
      {:ok, story_ids} ->
        get_stories(story_ids, limit)

      _ ->
        :error
    end
  end

  defp get_top_stories_ids() do
    get_json("#{@base_url}/topstories.json")
  end

  defp get_story(story_id) do
    get_json("#{@base_url}/item/#{story_id}.json")
  end

  defp get_stories(story_ids, limit) do
    stream =
      story_ids
      |> Enum.take(limit)
      |> Task.async_stream(&get_story/1, timeout: @task_timeout)

    if Enum.all?(stream, fn
         {:ok, {:ok, _}} -> true
         _ -> false
       end) do
      stream
      |> Enum.map(fn {:ok, {:ok, result}} -> result end)
      |> then(&{:ok, &1})
    else
      # TODO: log the error
      :error
    end
  end

  defp get_json(url) do
    with {:ok, response} <- Req.get(url, Application.get_env(:hnapi, :hn_req_opts, [])),
         true <- response.status in 200..299,
         true <- application_json?(response),
         true <- is_list(response.body) or is_map(response.body) do
      {:ok, response.body}
    else
      _ -> :error
    end
  end

  defp application_json?(response) do
    response.headers
    |> Map.get("content-type", [])
    |> Enum.any?(fn content_type ->
      String.contains?(content_type, "application/json")
    end)
  end
end
