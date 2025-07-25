defmodule Hnapi.Timer.Worker do
  @moduledoc """
  A worker that polls the top stories from Hacker News.

  It uses a timer to poll the stories every 5 minutes.
  """

  use GenServer

  def start_link(interval) do
    GenServer.start_link(__MODULE__, interval, name: __MODULE__)
  end

  def init(interval) do
    trigger_fetch()

    {:ok, interval}
  end

  def handle_info(:init_stories, state) do
    fetch_and_store_stories()
    schedule_fetch(state)

    {:noreply, state}
  end

  def handle_info(:update_stories, state) do
    old_stories = Hnapi.Datastore.Server.get_stories()

    case fetch_and_store_stories() do
      :error -> :error
      new_stories -> notify_stories_updated(new_stories, old_stories)
    end

    schedule_fetch(state)

    {:noreply, state}
  end

  # This may take a while, we could do this in a separate process.
  # But the worker runs not often, so it's not a big deal.
  defp fetch_and_store_stories do
    case Hnapi.Hn.Client.get_top_stories() do
      {:ok, stories} ->
        stories
        |> tap(&Hnapi.Datastore.Server.store_stories/1)
        |> Enum.map(&Hnapi.Helper.story_recap/1)

      :error ->
        :error
    end
  end

  defp trigger_fetch do
    Process.send(self(), :init_stories, [])
  end

  # We could use a pubsub library to notify the channel.
  # But the worker is really not a business logic of the application,
  # so we keep it simple.
  defp notify_stories_updated(new_stories, old_stories) do
    # Notify only if stories have changed
    # Send the entire new list of stories, to have a correct ordering on the client side
    if new_stories != old_stories do
      HnapiWeb.Endpoint.broadcast("stories:lobby", "stories_updated", %{
        stories: new_stories
      })
    end
  end

  defp schedule_fetch(interval) do
    Process.send_after(self(), :update_stories, interval)
  end
end
