defmodule MinimalServer.API do
  use Plug.Router # same as Router module, lol

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  @doc """
  Generates and fires a CycleComplete message with given fields.
  """
  def complete_cycle(machine_id, timestamp) do
    GenServer.call(MachineCycles, %{"machine_id" => machine_id,
                              "type" => "CycleComplete",
                              "timestamp" => timestamp})
  end

  post "/events" do
    IO.inspect conn
    %{"machine_id" => id, "time" => time} = conn.body_params
    complete_cycle(id, time)
    send_resp(conn, 200, "POST success!")
  end

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  defp message do
    %{
      time: DateTime.utc_now(),
      msg: "Hello world"
    }
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
