defmodule Hnapi.Datastore.Server do
  @moduledoc """
  Local store for the top stories.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{stories: %{}}}
  end

  @spec add_stories(any()) :: :ok
  def add_stories(stories) do
    GenServer.cast(__MODULE__, {:add_stories, stories})

    :ok
  end

  @spec get_stories() :: any()
  def get_stories() do
    GenServer.call(__MODULE__, :get_stories)
  end

  def handle_cast({:add_stories, stories}, state) do
    # We could extract logic for updating stories into a separate module for better testability
    # but for now it's simple enough to keep it here
    {:noreply, %{state | stories: Map.merge(state.stories, stories)}}
  end

  def handle_call(:get_stories, _from, state) do
    {:reply, state.stories, state}
  end
end
