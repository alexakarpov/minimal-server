# OH COME ON! The Endpoint and Router are just fancy names! The real difference is Endpoint module is a child of a Supervised Application. For example, this "Router" directly serves a request.

defmodule MinimalServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  IO.puts "beginning of #{ __ENV__.file}:#{__ENV__.line}"

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  defp message do
    %{
      # yeah makes sense - every req routed here will cause this fun to be called.
      #time: :calendar.universal_time(),
      time: DateTime.utc_now(),
      response_type: "in_channel",
      text: "Hello from BOT :)"
    }
  end
  IO.puts "end of #{ __ENV__.file}:#{__ENV__.line}"
end
