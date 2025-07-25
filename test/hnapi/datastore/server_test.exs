defmodule Hnapi.DatastoreTest do
  use ExUnit.Case

  setup do
    # Restart application to ensure clean state for every test.
    # NOTE We could configure the test env to skip starting the datastore and run it manually here.
    :ok = Application.stop(:hnapi)
    :ok = Application.start(:hnapi)
  end

  test "stores and returns stories" do
    Hnapi.Datastore.store_stories([%{"id" => 1}])

    assert Hnapi.Datastore.get_stories() == [%{"id" => 1}]
  end

  test "overrides existing stories with new data" do
    Hnapi.Datastore.store_stories([
      %{"id" => 1, "title" => "title1"},
      %{"id" => 2, "title" => "title2"}
    ])

    Hnapi.Datastore.store_stories([
      %{"id" => 1, "title" => "title1a"},
      %{"id" => 2, "title" => "title2a"}
    ])

    assert Hnapi.Datastore.get_stories() == [
             %{"id" => 1, "title" => "title1a"},
             %{"id" => 2, "title" => "title2a"}
           ]
  end

  test "returns stories for a given page and limit" do
    Hnapi.Datastore.store_stories([
      %{"id" => 1, "title" => "title1"},
      %{"id" => 2, "title" => "title2"},
      %{"id" => 3, "title" => "title3"},
      %{"id" => 4, "title" => "title4"},
      %{"id" => 5, "title" => "title5"}
    ])

    assert Hnapi.Datastore.get_stories(1, 2) == [
             %{"id" => 1, "title" => "title1"},
             %{"id" => 2, "title" => "title2"}
           ]

    assert Hnapi.Datastore.get_stories(2, 2) == [
             %{"id" => 3, "title" => "title3"},
             %{"id" => 4, "title" => "title4"}
           ]

    assert Hnapi.Datastore.get_stories(3, 2) == [
             %{"id" => 5, "title" => "title5"}
           ]
  end

  test "returns story by id" do
    Hnapi.Datastore.store_stories([
      %{"id" => 1, "title" => "title1"},
      %{"id" => 2, "title" => "title2"}
    ])

    assert Hnapi.Datastore.get_story(1) == %{"id" => 1, "title" => "title1"}
    assert Hnapi.Datastore.get_story(2) == %{"id" => 2, "title" => "title2"}
  end

  test "returns nil for non existing story" do
    assert Hnapi.Datastore.get_story(1) == nil
  end

  test "returns selected fields from the story" do
    Hnapi.Datastore.store_stories([
      %{"id" => 1, "title" => "title1", "url" => "url1"}
    ])

    assert Hnapi.Datastore.get_story(1) == %{
             "id" => 1,
             "title" => "title1",
             "url" => "url1"
           }
  end
end
