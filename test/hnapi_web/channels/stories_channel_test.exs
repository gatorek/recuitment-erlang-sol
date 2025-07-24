defmodule HnapiWeb.StoriesChannelTest do
  use HnapiWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      HnapiWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(HnapiWeb.StoriesChannel, "stories:lobby")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
