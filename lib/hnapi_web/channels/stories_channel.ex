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

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
