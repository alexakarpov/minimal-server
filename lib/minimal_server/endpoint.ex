defmodule MinimalServer.Endpoint do
  use Plug.Router

  IO.puts "at the root of #{ __ENV__.file}:#{__ENV__.line} - this will print once on COMPILE (which may coincide with 'mix run..')"
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison,
    foo: (IO.puts "lol" # this will also print once on compile
          42)           # .. this becomes some config, I guess?
  )

  plug(:dispatch)


  # this forward must precede the next clause, otherwise:
  # warning: this clause cannot match because a previous clause at line 17 always matches
  forward("/bot", to: MinimalServer.Router) #does position matter?

  match _ do
    IO.puts "404 - INSIDE #{ __ENV__.file}:#{__ENV__.line}"
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

end
