defmodule MinimalServerTest do
  use ExUnit.Case
  doctest MinimalServer

  test "greets the world" do
    IO.puts "is this even running? yes"
    assert MinimalServer.hello() == :world
  end
end
