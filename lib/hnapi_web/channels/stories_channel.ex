defmodule HnapiWeb.StoriesChannel do
  use HnapiWeb, :channel

  @impl true
  def join("stories:lobby", payload, socket) do
    if authorized?(payload) do
      stories = Hnapi.Datastore.Server.get_stories()

      {:ok, %{stories: stories}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
