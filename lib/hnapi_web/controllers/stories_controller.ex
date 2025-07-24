defmodule HnapiWeb.StoriesController do
  use HnapiWeb, :controller

  def index(conn, _params) do
    stories =
      Hnapi.Datastore.Server.get_stories()
      |> Map.values()

    json(conn, stories)
  end
end
