defmodule AlohaTest do
  use ExUnit.Case
  doctest Aloha

  test "greets the world" do
    assert Aloha.hello() == :world
  end
end
