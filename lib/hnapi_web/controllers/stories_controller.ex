defmodule HnapiWeb.StoriesController do
  use HnapiWeb, :controller

  @default_page 1
  @default_limit 10

  def index(conn, params) do
    with {:ok, page} <- parse_int(params["page"], @default_page),
         {:ok, limit} <- parse_int(params["limit"], @default_limit) do
      json(conn, Hnapi.Datastore.get_stories(page, limit))
    else
      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid parameter"})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, id} <- parse_int(id, 0),
         story when not is_nil(story) <- Hnapi.Datastore.get_story(id) do
      json(conn, story)
    else
      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid parameter"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Story not found"})
    end
  end

  # Helper functions for testing
  def default_page(), do: @default_page
  def default_limit(), do: @default_limit

  defp parse_int(param, default) do
    with false <- is_nil(param),
         {integer, ""} <- Integer.parse(param) do
      {:ok, integer}
    else
      true -> {:ok, default}
      _ -> :error
    end
  end
end
