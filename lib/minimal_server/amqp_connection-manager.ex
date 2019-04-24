defmodule AMQP.ConnectionManager do
  use GenServer
  require Logger
  alias AMQP.Connection

  @host Application.get_env(:minimal_server, :rabbit_host)
  @reconnect_interval 10_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, name: ConnMan)
  end

  def init(_) do
    send(self(), :connect)
    Logger.warn (inspect self())
    {:ok, nil}
  end

  def get_connection do
    Logger.debug "calling #{__MODULE__}'s :get"
    case GenServer.call(ConnMan, :get) do
      nil -> {:error, :not_connected}
      conn -> {:ok, conn}
    end
  end

  def handle_call(:get, _, conn) do
    Logger.debug("well?")
    {:reply, conn, conn}
  end

  def handle_info(:connect, conn) do
    case Connection.open(@host) do
      {:ok, conn} ->
        # Get notifications when the connection goes down
        Process.monitor(conn.pid)
        {:noreply, conn}

      {:error, msg} ->
        Logger.error("Failed to connect to #{@host}. Reconnecting later...")
        Logger.error(IO.inspect msg)
        # Retry later
        Process.send_after(self(), :connect, @reconnect_interval)
        {:noreply, nil}
    end
  end

  def handle_info({:DOWN, _, :process, _pid, reason}, _) do
    # Stop GenServer. Will be restarted by Supervisor.
    {:stop, {:connection_lost, reason}, nil}
  end
end
