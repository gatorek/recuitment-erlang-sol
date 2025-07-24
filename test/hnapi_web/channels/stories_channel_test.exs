defmodule HnapiWeb.StoriesChannelTest do
  use HnapiWeb.ChannelCase
  use Mimic

  setup :verify_on_exit!

  test "sends stories to client on join" do
    # Mock the Datastore.Server to return some test stories
    expect(Hnapi.Datastore.Server, :get_stories, fn ->
      [
        %{"id" => 1, "title" => "Test Story 1"},
        %{"id" => 2, "title" => "Test Story 2"}
      ]
    end)

    {:ok, reply, _socket} = connect_socket()

    # Assert that the reply contains the stories
    assert reply == %{
             stories: [
               %{"id" => 1, "title" => "Test Story 1"},
               %{"id" => 2, "title" => "Test Story 2"}
             ]
           }
  end

  test "broadcasts are pushed to the client" do
    # Mock the Datastore.Server for the join
    stub(Hnapi.Datastore.Server, :get_stories, fn -> %{} end)

    {:ok, _reply, socket} = connect_socket()
    broadcast_from!(socket, "broadcast", %{"some" => "data"})

    assert_push "broadcast", %{"some" => "data"}
  end

  defp connect_socket() do
    HnapiWeb.UserSocket
    |> socket("user_id", %{some: :assign})
    |> subscribe_and_join(HnapiWeb.StoriesChannel, "stories:lobby")
  end
end
