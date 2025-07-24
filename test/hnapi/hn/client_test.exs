defmodule Hnapi.Hn.ClientTest do
  use ExUnit.Case

  test "returns empty map when no top stories" do
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [])
    end)

    assert Hnapi.Hn.Client.get_top_stories() == []
  end

  test "returns stories data" do
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113])
    end)

    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/item/112.json"

      Req.Test.json(conn, %{
        "by" => "user1",
        "descendants" => 1,
        "id" => 112,
        "kids" => [1],
        "score" => 1,
        "time" => 1,
        "title" => "title1",
        "type" => "story",
        "url" => "url1"
      })
    end)

    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/item/113.json"

      Req.Test.json(conn, %{
        "by" => "user2",
        "descendants" => 2,
        "id" => 113,
        "kids" => [123, 124],
        "score" => 4,
        "time" => 123,
        "title" => "title2",
        "type" => "story",
        "url" => "url2"
      })
    end)

    assert Hnapi.Hn.Client.get_top_stories() ==
             [
               %{
                 "by" => "user1",
                 "descendants" => 1,
                 "id" => 112,
                 "kids" => [1],
                 "score" => 1,
                 "time" => 1,
                 "title" => "title1",
                 "type" => "story",
                 "url" => "url1"
               },
               %{
                 "by" => "user2",
                 "descendants" => 2,
                 "id" => 113,
                 "kids" => [123, 124],
                 "score" => 4,
                 "time" => 123,
                 "title" => "title2",
                 "type" => "story",
                 "url" => "url2"
               }
             ]
  end

  test "honors limit when fetching stories" do
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113, 114, 115])
    end)

    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/item/112.json"

      Req.Test.json(conn, %{"id" => 112})
    end)

    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/item/113.json"

      Req.Test.json(conn, %{"id" => 113})
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) == [
             %{"id" => 112},
             %{"id" => 113}
           ]
  end

  # TODO: tests HN client error handling after implementation
  @tag skip: "ignore errors for now"
  test "handles connection errors" do
    assert false
  end
end
