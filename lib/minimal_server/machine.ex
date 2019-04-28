defmodule MinimalServer.Machine do
  use GenServer
  require Logger
  require AtomicMap

  def start_link(opts) do
    Logger.debug opts
    {:ok, journal} = File.open("journal.log", [:utf8, :write])
    Logger.info "journal opened; starting the MinimalServer.Machine"
    GenServer.start_link(__MODULE__, journal, name: MachineCycles)
  end

  #Server callbacks

  @impl true
  def init(journal) do
    {:ok, %{journal: journal,
            machines: %{}}}
  end

  @impl GenServer
  def handle_call(event = %{"type" => "CycleComplete",
                            "machine_id" => m_id,
                            "timestamp" => _ts}, _from,
    state = %{journal: journal, machines: _machines}) do

    # I find atoms to be better for map keys.
    event = AtomicMap.convert(event)
    Machine.Helper.record_cycle_complete(journal, event)
    # this will produce an entry for _all_ new machines - including the original one.
    if state.machines[event.machine_id] == nil do
      Machine.Helper.record_new_machine(journal, event.machine_id, event.timestamp)
    end
    # update our timers map
    new_machines = Machine.Helper.set_or_reset_timer(Map.get(state, :machines), m_id)
    {:reply, :ok, Map.put(state, :machines, new_machines)}
  end

  @impl GenServer
  def handle_call(msg, _from, state) do
    Logger.warn("Unsupported message: " <> inspect msg)
    {:reply, {:error, :unsupported}, state}
  end

  # Log the first timeout, and start the alarm one
  @impl GenServer
  def handle_info({:late, machine_id}, state=%{journal: journal, machines: _machines}) do
    Machine.Helper.record_lapse(journal, "NonProductionLimitReached", machine_id)
    {:noreply, put_in(state, [:machines, machine_id], Process.send_after(self(), {:real_late, machine_id}, Application.get_env(:minimal_server, :alarm_timeout)))}
  end

  # Log the alarm for the real_late timer's expiration.
  @impl GenServer
  def handle_info({:real_late, machine_id}, state=%{journal: journal, machines: _machines}) do
    Machine.Helper.record_lapse(journal, "AlarmOpened", machine_id)
    {:noreply, state}
  end
end
