defmodule Hnapi.Timer.WorkerTest do
  use ExUnit.Case
  use Mimic

  # How often the worker should fetch stories
  @interval 1500
  # How long we should wait after the last fetch
  @additional_interval 500

  setup :set_mimic_global
  setup :verify_on_exit!

  @tag skip: "slow test; might be flaky; use `--include skip` if needed"
  test "fetches and stores stories" do
    # Set up expectations for the initial fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, [%{"id" => 1}]} end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Set up expectations for the scheduled fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, [%{"id" => 2}]} end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 2}] -> :ok end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 2}] end)
    expect(HnapiWeb.Endpoint, :broadcast, fn _, _, _ -> :ok end)

    # Wait for the worker to fetch stories
    Process.sleep(@interval)
    # And wait a bit longer to ensure the scheduled fetch is processed
    Process.sleep(@additional_interval)
  end

  @tag skip: "slow test; might be flaky; use `--include skip` if needed"
  test "do not notify if stories have not changed" do
    # Initial fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, [%{"id" => 1}]} end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Scheduled fetch
    # Do not expect to receive any notifications
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, [%{"id" => 1}]} end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 1}] end)

    # Wait for the worker to fetch and process the stories
    Process.sleep(@interval)
    Process.sleep(@additional_interval)
  end

  @tag skip: "slow test; might be flaky; use `--include skip` if needed"
  test "handles errors in scheduled fetch" do
    # Initial fetch went ok
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, [%{"id" => 1}]} end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Scheduled fetch failed
    # Do not store or notify after receiving an error from Hn Client
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> :error end)

    # Wait for the worker to fetch and process the stories
    Process.sleep(@interval)
    Process.sleep(@additional_interval)
  end

  @tag skip: "slow test; might be flaky; use `--include skip` if needed"
  test "handles errors in initial fetch" do
    # Initial fetch failed - do not store or notify
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> :error end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Scheduled fetch succedeed
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, [%{"id" => 2}]} end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 2}] -> :ok end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 2}] end)
    expect(HnapiWeb.Endpoint, :broadcast, fn _, _, _ -> :ok end)

    # Wait for the worker to fetch and process the stories
    Process.sleep(@interval)
    Process.sleep(@additional_interval)
  end

  @tag skip: "slow test; might be flaky; use `--include skip` if needed"
  test "send broadcast to the channel" do
    full_stories = [
      %{"id" => 1, "title" => "title1", "url" => "url1", "text" => "text1"},
      %{"id" => 2, "title" => "title2", "url" => "url2", "text" => "text2", "by" => "user2"}
    ]

    short_stories = [
      %{"id" => 1, "title" => "title1", "url" => "url1"},
      %{"id" => 2, "title" => "title2", "url" => "url2", "by" => "user2"}
    ]

    # Set up expectations for the initial fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, []} end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [] -> :ok end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Set up expectations for the scheduled fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> {:ok, full_stories} end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn _ -> :ok end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> short_stories end)

    expect(HnapiWeb.Endpoint, :broadcast, fn topic, event, data ->
      assert topic == "stories:lobby"
      assert event == "stories_updated"
      assert data == %{stories: short_stories}

      :ok
    end)

    Process.sleep(@interval)
    Process.sleep(@additional_interval)
  end
end
