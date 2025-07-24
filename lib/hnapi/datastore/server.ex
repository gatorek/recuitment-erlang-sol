defmodule Hnapi.Datastore.Server do
  @moduledoc """
  Local store for the top stories.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{stories: []}}
  end

  @spec store_stories(any()) :: :ok
  def store_stories(stories) do
    GenServer.cast(__MODULE__, {:store_stories, stories})

    :ok
  end

  @spec get_stories() :: any()
  def get_stories() do
    GenServer.call(__MODULE__, :get_stories)
  end

  def handle_cast({:store_stories, stories}, state) do
    {:noreply, %{state | stories: stories}}
  end

  def handle_call(:get_stories, _from, state) do
    {:reply, state.stories, state}
  end
end
