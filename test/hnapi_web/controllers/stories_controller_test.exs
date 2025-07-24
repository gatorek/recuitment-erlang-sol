defmodule HnapiWeb.StoriesControllerTest do
  use HnapiWeb.ConnCase
  use Mimic

  setup :verify_on_exit!

  describe "GET /api/stories" do
    test "returns empty map for empty stories", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn -> [] end)

      response =
        conn
        |> get("/api/stories")
        |> json_response(200)

      assert response == []
    end

    test "returns stories data for non empty stories", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 1}] end)

      response =
        conn
        |> get("/api/stories")
        |> json_response(200)

      assert response == [%{"id" => 1}]
    end
  end
end
