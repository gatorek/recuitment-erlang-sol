defmodule Hnapi.Helper do
  @moduledoc """
  Helper functions for the application.
  """

  @type story :: Hnapi.HackerNewsClient.story()

  @recap_fields ~w[id by title url]

  @spec story_recap(story) :: story
  def story_recap(story) do
    Map.take(story, @recap_fields)
  end
end
