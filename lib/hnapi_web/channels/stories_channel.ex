defmodule HnapiWeb.StoriesChannel do
  @moduledoc """
  A channel for stories.
  """
  use HnapiWeb, :channel

  @impl true
  def join("stories:lobby", _payload, socket) do
    stories = Hnapi.Datastore.Server.get_stories()

    {:ok, %{stories: stories}, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end
end
