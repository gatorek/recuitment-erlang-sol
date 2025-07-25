defmodule Hnapi.Hn.Client do
  @moduledoc """
  A client for the Hacker News API.

  It uses Req for HTTP requests.
  """

  require Logger

  @type id :: non_neg_integer()
  # NOTE We could use atom keys, to get a better type safety.
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
    results =
      story_ids
      |> Enum.take(limit)
      |> Task.async_stream(&get_story/1, timeout: @task_timeout)
      |> Enum.reduce({:ok, []}, fn
        {:ok, {:ok, result}}, {status, acc} ->
          {status, [result | acc]}

        {:ok, :error}, {_, acc} ->
          {:error, acc}

        {:exit, reason}, {_, acc} ->
          Logger.error("Failed to get story: Task error - #{inspect(reason)}")
          {:error, acc}
      end)

    case results do
      {:ok, stories} -> {:ok, Enum.reverse(stories)}
      {:error, _} -> :error
    end
  end

  defp get_json(url) do
    with {:ok, response} <- Req.get(url, Application.get_env(:hnapi, :hn_req_opts, [])),
         {:status, true} <- {:status, response.status in 200..299},
         {:content_type, true} <- {:content_type, application_json?(response)},
         {:body, true} <- {:body, is_list(response.body) or is_map(response.body)} do
      {:ok, response.body}
    else
      {:error, response} -> log_error("Connection error: #{inspect(response)}")
      {:status, false} -> log_error("API call returned non-2xx status")
      {:content_type, false} -> log_error("Invalid content type")
      {:body, false} -> log_error("Invalid response body")
    end
  end

  defp log_error(reason) do
    Logger.error("Failed to get story: #{reason}")
    :error
  end

  defp application_json?(response) do
    response.headers
    |> Map.get("content-type", [])
    |> Enum.any?(fn content_type ->
      String.contains?(content_type, "application/json")
    end)
  end
end
