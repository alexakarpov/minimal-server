defmodule MS.Server do
  use GenServer
  require Logger
  require AtomicMap

  ## Client API

  @doc """
  Starts a named MachineStateServer .
  """
  def start_server() do
    # journals' just a file for now
    {:ok, journal} = File.open("journal", [:write])
    GenServer.start_link(__MODULE__, journal, name: MachineStateServer)
    :ok
  end

  @doc """
  Generates and fires a CycleComplete message with given fields.
  """
  def complete_cycle(machine_id, timestamp) do
    GenServer.call(MachineStateServer, %{"machine_id" => machine_id,
                                         "type" => "CycleComplete",
                                         "timestamp" => timestamp})
  end

  #Server Callbacks

  def init(journal) do
    {:ok, %{journal: journal,
            machines: %{}}}
  end

  def handle_call(event = %{"type" => "CycleComplete",
                            "machine_id" => m_id,
                            "timestamp" => _ts}, _from,
    state = %{journal: journal, machines: _machines}) do

    # I find atoms to be better for map keys.
    event = AtomicMap.convert(event)
    MS.Helper.record_cycle_complete(journal, event)
    # Note: this will produce an entry for _all_ new machines - including the original one.
    if state.machines[event.machine_id] == nil do
      MS.Helper.record_new_machine(journal, event.machine_id, event.timestamp)
    end
    # update our timers map, now that this guy did some work
    new_machines = MS.Helper.set_or_reset_timer(Map.get(state, :machines), m_id)
    {:reply, :ok, Map.put(state, :machines, new_machines)}
  end

  def handle_call(msg, _from, state) do
    Logger.warn("Unsupported message: " <> inspect msg)
    {:reply, {:error, :unsupported}, state}
  end

  # Log the first timeout, and start the alarm one
  def handle_info({:late, machine_id}, state=%{journal: journal, machines: _machines}) do
    MS.Helper.record_lapse(journal, "NonProductionLimitReached", machine_id)
    {:noreply, put_in(state, [:machines, machine_id], Process.send_after(self(), {:real_late, machine_id}, 15_000))}
  end

  # Log the alarm for the real_late timer's expiration.
  def handle_info({:real_late, machine_id}, state=%{journal: journal, machines: _machines}) do
    MS.Helper.record_lapse(journal, "AlarmOpened", machine_id)
    {:noreply, state}
  end
end
