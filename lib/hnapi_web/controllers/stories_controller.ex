defmodule HnapiWeb.StoriesController do
  use HnapiWeb, :controller

  @default_page 1
  @default_limit 10

  def index(conn, params) do
    page = parse_int(params["page"], @default_page)
    limit = parse_int(params["limit"], @default_limit)

    json(conn, Hnapi.Datastore.Server.get_stories(page, limit))
  end

  def show(conn, %{"id" => id}) do
    # TODO: handle invalid id; for now we relay on datastore to return nil
    id = parse_int(id, 0)
    story = Hnapi.Datastore.Server.get_story(id)

    if story do
      json(conn, story)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Story not found"})
    end
  end

  # Helper functions for testing
  def default_page(), do: @default_page
  def default_limit(), do: @default_limit

  defp parse_int(param, default) do
    case Integer.parse(param || "") do
      {int_param, _} -> int_param
      _ -> default
    end
  end
end
