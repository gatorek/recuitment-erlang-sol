defmodule Hnapi.Datastore.Server do
  @moduledoc """
  Local store for the top stories.
  """

  @type stories :: Hnapi.Hn.Client.stories()
  @type page :: non_neg_integer()
  @type limit :: non_neg_integer()

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{stories: []}}
  end

  @spec store_stories(stories) :: :ok
  def store_stories(stories)
      # Basic validation, to make sure that we won't crash the server
      when is_list(stories) do
    GenServer.cast(__MODULE__, {:store_stories, stories})

    :ok
  end

  @spec get_stories() :: stories
  def get_stories() do
    GenServer.call(__MODULE__, :get_stories)
  end

  @spec get_stories(page, limit) :: stories
  def get_stories(page, limit)
      # Basic validation, to make sure that we won't crash the server
      when is_integer(page) and is_integer(limit) and page > 0 and limit > 0 do
    GenServer.call(__MODULE__, {:get_stories, page, limit})
  end

  def handle_cast({:store_stories, stories}, state) do
    {:noreply, %{state | stories: stories}}
  end

  def handle_call(:get_stories, _from, state) do
    {:reply, state.stories, state}
  end

  def handle_call({:get_stories, page, limit}, _from, state) do
    # If we need to add more business logic, we should extract it to a separate module.
    # For now, with this simple implementation we can just put it here.
    {:reply, Enum.slice(state.stories, (page - 1) * limit, limit), state}
  end
end
