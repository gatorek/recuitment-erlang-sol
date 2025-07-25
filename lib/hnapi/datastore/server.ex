defmodule Hnapi.Datastore.Server do
  @moduledoc """
  Local store for the top stories.
  """

  use GenServer

  import Hnapi.Helper

  @type page :: non_neg_integer()
  @type limit :: non_neg_integer()
  @type id :: non_neg_integer()
  @type story :: Hnapi.Hn.Client.story()

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{stories: []}}
  end

  @spec store_stories([story]) :: :ok
  def store_stories(stories)
      # Basic validation, to make sure that we won't crash the server
      when is_list(stories) do
    GenServer.cast(__MODULE__, {:store_stories, stories})

    :ok
  end

  @spec get_stories() :: [story]
  def get_stories() do
    GenServer.call(__MODULE__, :get_stories)
  end

  @spec get_stories(page, limit) :: [story]
  def get_stories(page, limit)
      # Basic validation, to make sure that we won't crash the server
      when is_integer(page) and is_integer(limit) and page > 0 and limit > 0 do
    GenServer.call(__MODULE__, {:get_stories, page, limit})
  end

  @spec get_story(id) :: story | nil
  def get_story(id) do
    GenServer.call(__MODULE__, {:get_story, id})
  end

  def handle_cast({:store_stories, stories}, state) do
    {:noreply, %{state | stories: stories}}
  end

  def handle_call(:get_stories, _from, state) do
    state.stories
    |> Enum.map(&story_recap/1)
    |> then(&{:reply, &1, state})
  end

  def handle_call({:get_stories, page, limit}, _from, state) do
    state.stories
    |> paginate(page, limit)
    |> Enum.map(&story_recap/1)
    |> then(&{:reply, &1, state})
  end

  def handle_call({:get_story, id}, _from, state) do
    {:reply, Enum.find(state.stories, fn story -> story["id"] == id end), state}
  end

  def paginate(stories, page, limit) do
    Enum.slice(stories, (page - 1) * limit, limit)
  end
end
