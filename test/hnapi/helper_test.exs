defmodule Hnapi.TestHelper do
  use ExUnit.Case

  import Hnapi.Helper

  describe "story_recap/1" do
    test "short_data" do
      story = %{
        "id" => 1,
        "title" => "title1",
        "url" => "url1",
        "text" => "text1",
        "by" => "user1"
      }

      assert story_recap(story) == %{
               "id" => 1,
               "title" => "title1",
               "url" => "url1",
               "by" => "user1"
             }

      assert story_recap(story) == %{
               "id" => 1,
               "title" => "title1",
               "url" => "url1",
               "by" => "user1"
             }
    end

    test "ignores missing fields" do
      story = %{
        "id" => 1,
        "some" => "field"
      }

      assert story_recap(story) == %{
               "id" => 1
             }
    end
  end
end
