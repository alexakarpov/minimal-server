
defmodule MinimalServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)


  IO.puts "ohai from #{ __ENV__.file} at #{__ENV__.line}"

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  defp message do
    %{
      doo: (IO.puts "hi from inside of a fun #{ __ENV__.file} at #{__ENV__.line}; this will print on every request made"),
      response_type: "in_channel",
      text: "Hello from BOT :)"
    }
  end
  IO.puts "ohai from #{ __ENV__.file} at #{__ENV__.line}"
end

# defmodule MinimalServer.Router do
#   use Plug.Router

#   plug(:match)
#   plug(:dispatch)

#   @content_type "application/json"

#   get "/" do
#     conn
#     |> put_resp_content_type(@content_type)
#     |> send_resp(200, message())
#   end

#   match _ do
#     send_resp(conn, 404, "Requested page not found!")
#   end

#   defp message do
#     Poison.encode!(%{
#           response_type: "in_channel",
#           text: "Hello from BOT :)"
#                    })
#   end
# end
