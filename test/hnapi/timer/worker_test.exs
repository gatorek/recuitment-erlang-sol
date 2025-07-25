defmodule Hnapi.Timer.WorkerTest do
  use ExUnit.Case, async: false
  use Mimic

  # How often the worker should fetch stories
  @interval :timer.seconds(1)
  # How long we should wait after the last fetch
  @additional_interval 100

  setup :set_mimic_global
  setup :verify_on_exit!

  test "fetches and stores stories" do
    # Set up expectations for the initial fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Set up expectations for the scheduled fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> [%{"id" => 2}] end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 2}] -> :ok end)
    expect(HnapiWeb.Endpoint, :broadcast, fn _, _, _ -> :ok end)

    # Wait for the worker to fetch stories
    Process.sleep(@interval)
    # And wait a bit longer to ensure the scheduled fetch is processed
    Process.sleep(@additional_interval)
  end

  test "do not notify if stories have not changed" do
    # Initial fetch
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)

    {:ok, _pid} = start_supervised({Hnapi.Timer.Worker, @interval})

    # Scheduled fetch
    # Do not expect to receive any notifications
    expect(Hnapi.Hn.Client, :get_top_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :get_stories, fn -> [%{"id" => 1}] end)
    expect(Hnapi.Datastore.Server, :store_stories, fn [%{"id" => 1}] -> :ok end)

    # Wait for the worker to fetch and process the stories
    Process.sleep(@interval)
    Process.sleep(@additional_interval)
  end
end
