defmodule MinimalServer.API.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts MinimalServer.API.init([])

  test "get to /hello returns 'world'" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = MinimalServer.API.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "world"
  end
end
