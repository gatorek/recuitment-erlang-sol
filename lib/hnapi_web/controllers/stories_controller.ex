defmodule HnapiWeb.StoriesController do
  use HnapiWeb, :controller

  def index(conn, _params) do
    json(conn, Hnapi.Datastore.Server.get_stories())
  end
end
