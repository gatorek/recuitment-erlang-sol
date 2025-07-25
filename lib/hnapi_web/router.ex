defmodule HnapiWeb.Router do
  use HnapiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HnapiWeb do
    pipe_through :api
    get "/stories", StoriesController, :index
    get "/stories/:id", StoriesController, :show
  end
end
