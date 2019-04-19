# OH COME ON! The Endpoint and Router are just fancy names! The real difference is Endpoint module is a child of a Supervised Application.

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
      doo: (IO.puts "hi from inside of a fun #{ __ENV__.file}:#{__ENV__.line}; prints on every request served"),
      response_type: "in_channel",
      text: "Hello from BOT :)"
    }
  end
  IO.puts "end of #{ __ENV__.file}:#{__ENV__.line}"
end
