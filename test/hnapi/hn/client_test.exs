defmodule Hnapi.Hn.ClientTest do
  use ExUnit.Case
  import Req.Test

  setup :set_req_test_to_shared

  test "returns empty map when no top stories" do
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [])
    end)

    assert Hnapi.Hn.Client.get_top_stories() == {:ok, []}
  end

  test "returns stories data" do
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113])
    end)

    # Use stub because of random ordering of requests
    Req.Test.stub(Hnapi.Hn.Client, fn
      conn = %{request_path: "/v0/item/112.json"} ->
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

      conn = %{request_path: "/v0/item/113.json"} ->
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
             {:ok,
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
              ]}
  end

  test "honors limit when fetching stories" do
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113, 114, 115])
    end)

    # Use stub because of random ordering of requests
    Req.Test.stub(Hnapi.Hn.Client, fn
      conn = %{request_path: "/v0/item/112.json"} ->
        Req.Test.json(conn, %{"id" => 112})

      conn = %{request_path: "/v0/item/113.json"} ->
        Req.Test.json(conn, %{"id" => 113})
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) ==
             {:ok,
              [
                %{"id" => 112},
                %{"id" => 113}
              ]}
  end

  @tag skip: "slow test due to Req retries; use `--include skip` if needed"
  test "returns error on connection errors" do
    # Expect to return top stories ids
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113, 114, 115])
    end)

    # Expect to timeout fetching stories (req will retry)
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      Req.Test.transport_error(conn, :timeout)
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) == :error
  end

  @tag skip: "slow test due to Req retries; use `--include skip` if needed"
  test "returns error on non-successful responses" do
    # Expect to return top stories ids
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113, 114, 115])
    end)

    # Expect to fail fetching stories (req will retry)
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      Req.Test.text(Plug.Conn.put_status(conn, 500), "fail")
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) == :error
  end

  test "returns error on responses with invalid content type" do
    # Expect to return top stories ids
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113, 114, 115])
    end)

    # Expect to return invalid content type
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      Req.Test.text(conn, "some content")
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) == :error
  end

  test "returns error on invalid json" do
    # Expect to return top stories ids
    Req.Test.expect(Hnapi.Hn.Client, fn conn ->
      assert conn.request_path == "/v0/topstories.json"

      Req.Test.json(conn, [112, 113, 114, 115])
    end)

    # Expect to return invalid content
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      Req.Test.json(conn, "some content")
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) == :error
  end

  @tag skip: "slow test due to Req retries; use `--include skip` if needed"
  test "returns error on empty list of top stories ids" do
    # Expect to fail fetching story ids
    Req.Test.stub(Hnapi.Hn.Client, fn conn ->
      Req.Test.transport_error(conn, :timeout)
    end)

    assert Hnapi.Hn.Client.get_top_stories(2) == :error
  end
end
