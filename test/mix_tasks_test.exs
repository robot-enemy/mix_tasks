defmodule MixTasksTest do
  use ExUnit.Case
  doctest MixTasks

  test "greets the world" do
    assert MixTasks.hello() == :world
  end
end
