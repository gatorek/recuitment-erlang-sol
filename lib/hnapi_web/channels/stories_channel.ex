defmodule HnapiWeb.StoriesChannel do
  use HnapiWeb, :channel

  @impl true
  def join("stories:lobby", payload, socket) do
    if authorized?(payload) do
      stories =
        Hnapi.Datastore.Server.get_stories()
        # TODO parsing response is duplicated here, but we'll get rid of it later
        |> Map.values()

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
