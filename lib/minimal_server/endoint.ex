defmodule MinimalServer.Endpoint do
  use Plug.Router

  IO.puts "before plug(:match)"
  plug(:match)
  IO.puts "after plug(:match)"

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end
