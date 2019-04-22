defmodule MinimalServer.Endpoint do
  use Plug.Router # same as Router module, lol

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  # this forward (nothing to do with 302) must precede the next clause, otherwise:
  # warning: this clause cannot match because a previous clause at line 17 always matches
  forward("/bot", to: MinimalServer.Router) # dependency
  # .. but what if we had more than 1?

  post "/events" do
    IO.inspect conn
    %{"machine_id" => id, "time" => time} = conn.body_params
    MinimalServer.Machine.complete_cycle(id, time)
    send_resp(conn, 200, "POST success!")
  end

  match _ do
    send_resp(conn, 404, "Requested url not found!")
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
