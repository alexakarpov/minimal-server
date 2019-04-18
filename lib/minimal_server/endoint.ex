defmodule MinimalServer.Endpoint do
  use Plug.Router

  IO.puts "before plug(:match)"
  plug(:match)
  IO.puts "after plug(:match)"

  # now where do I put this?
  forward(“/bot”, to: MinimalServer.Router) $ #does position matter?

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Plug.Adapters.Cowboy2.http(__MODULE__, [])
  end

end
