defmodule Hnapi.Datastore.ServerTest do
  use ExUnit.Case

  setup do
    # Restart application to ensure clean state for every test.
    # We could configure the test env to skip starting the datastore and run it manually here.
    # TODO maybe we should configure the test env to skip starting the datastore and run it manually here.
    :ok = Application.stop(:hnapi)
    :ok = Application.start(:hnapi)
  end

  test "add and get stories" do
    Hnapi.Datastore.Server.add_stories(%{1 => %{"id" => 1}})

    assert Hnapi.Datastore.Server.get_stories() == %{1 => %{"id" => 1}}
  end

  test "overrides existing stories with new data" do
    Hnapi.Datastore.Server.add_stories(%{
      1 => %{"id" => 1, "title" => "title1"},
      2 => %{"id" => 2, "title" => "title2"}
    })

    Hnapi.Datastore.Server.add_stories(%{1 => %{"id" => 1, "title" => "title1a"}})

    assert Hnapi.Datastore.Server.get_stories() == %{
             1 => %{"id" => 1, "title" => "title1a"},
             2 => %{"id" => 2, "title" => "title2"}
           }
  end
end
