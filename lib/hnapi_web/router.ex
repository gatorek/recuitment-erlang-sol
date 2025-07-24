defmodule HnapiWeb.Router do
  use HnapiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HnapiWeb do
    pipe_through :api
  end
end
