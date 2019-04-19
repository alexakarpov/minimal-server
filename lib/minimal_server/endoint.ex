defmodule MinimalServer.Endpoint do
  use Plug.Router

  IO.puts "ohai from #{ __ENV__.file} at #{__ENV__.line}"
  plug(:match)

  # now where do I put this?
  forward("/bot", to: MinimalServer.Router) #does position matter?

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  match _ do
    IO.puts "ohai from INSIDE #{ __ENV__.file} at #{__ENV__.line}"
    send_resp(conn, 404, "Requested page not found!")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Plug.Cowboy.http(__MODULE__, [])
  end
  IO.puts "ohai from #{ __ENV__.file} at #{__ENV__.line}"
end
