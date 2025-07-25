defmodule HnapiWeb.StoriesControllerTest do
  use HnapiWeb.ConnCase
  use Mimic

  setup :verify_on_exit!

  describe "GET /api/stories" do
    test "returns empty map for empty stories", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn _, _ -> [] end)

      response =
        conn
        |> get("/api/stories")
        |> json_response(200)

      assert response == []
    end

    test "returns stories data for non empty stories", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn _, _ -> [%{"id" => 1}] end)

      response =
        conn
        |> get("/api/stories")
        |> json_response(200)

      assert response == [%{"id" => 1}]
    end

    test "returns stories data for non empty stories with page and limit", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn page, limit ->
        assert page == 1
        assert limit == 2

        [
          %{"id" => 1},
          %{"id" => 2}
        ]
      end)

      response =
        conn
        |> get("/api/stories?page=1&limit=2")
        |> json_response(200)

      assert response == [%{"id" => 1}, %{"id" => 2}]
    end

    test "use default values for page and limit when missing params", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn page, limit ->
        assert page == HnapiWeb.StoriesController.default_page()
        assert limit == HnapiWeb.StoriesController.default_limit()
        []
      end)

      response =
        conn
        |> get("/api/stories")
        |> json_response(200)

      assert response == []
    end

    # TODO: we may want to return 400 Bad Request for invalid params.
    test "use default values for page and limit when invalid params", %{conn: conn} do
      expect(Hnapi.Datastore.Server, :get_stories, fn page, limit ->
        assert page == HnapiWeb.StoriesController.default_page()
        assert limit == HnapiWeb.StoriesController.default_limit()
        []
      end)

      response =
        conn
        |> get("/api/stories?page=invalid&limit=invalid")
        |> json_response(200)

      assert response == []
    end
  end
end
