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

  def handle_info(:fetch_stories, state) do
    fetch_and_store_stories()
    schedule_fetch(state)

    {:noreply, state}
  end

  defp fetch_and_store_stories do
    Hnapi.Hn.Client.get_top_stories()
    |> Hnapi.Datastore.Server.store_stories()
  end

  defp trigger_fetch do
    Process.send(self(), :fetch_stories, [])
  end

  defp schedule_fetch(interval) do
    Process.send_after(self(), :fetch_stories, interval)
  end
end
