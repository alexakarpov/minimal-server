defmodule MinimalServer.Endpoint do
  use Plug.Router

  #OK, so this module is a child of a Supervised application
  
  # any change to this file will cause only this module to recompile - while Router change will cause both modules to recompile, because this Endpoint module here depends on Router module
  IO.puts "at the root of #{ __ENV__.file}:#{__ENV__.line}"

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison,
    foo: (IO.puts "lol" # this will also print once on compile
          42)           # .. this becomes some config, I guess?
  )

  plug(:dispatch)

  # this forward ( nothing to do with 302) must precede the next clause, otherwise:
  # warning: this clause cannot match because a previous clause at line 17 always matches
  forward("/bot", to: MinimalServer.Router) # dependency
  # .. but what if we had more than 1?

  get "/hello" do
    # .. lol,sure!
    IO.puts "hello - at #{ __ENV__.file}:#{__ENV__.line}"
    send_resp(conn, 200, "world")
  end

  match _ do
    IO.puts "404 - at #{ __ENV__.file}:#{__ENV__.line}"
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
