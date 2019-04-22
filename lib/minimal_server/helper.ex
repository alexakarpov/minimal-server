defmodule Machine.Helper do
  require Timex
  require Logger
  require Poison
  require AtomicMap

  def stamp(event_map) do
    {:ok, time_now} = Timex.format(Timex.now, "%Y-%m-%dT%H:%M:%S", :strftime)
    Map.put(event_map, :recorded_at, time_now)
  end

  def foo do
    :baz
  end

  def build_message(type, machine_id, event_time) do
    %{type: type,
      machine_id: machine_id,
      event_time: event_time}
  end

  def keys_to_keywords(event) do
    AtomicMap.convert(event)
  end

  # Writing to journal

  @doc """
  hm, if Kafka client for Elixir is also just an IODevice, this might work
  """
  def record_cycle_complete(journal, %{machine_id: machine_id,
                                       type: "CycleComplete",
                                       timestamp: ts}) do
    {:ok, event_to_write} = Poison.encode(stamp(build_message("MachineCycled", machine_id, ts)))
    IO.puts(journal, event_to_write)
    {:ok, event_to_write}
  end

  def record_lapse(journal, lapse_type, machine_id) do
    {:ok, time_now} = Timex.format(Timex.now, "%Y-%m-%dT%H:%M:%S", :strftime)
    {:ok, event_to_write} = Poison.encode(stamp(build_message(lapse_type, machine_id, time_now)))
    IO.puts(journal, event_to_write)
  end

  def record_new_machine(journal, machine_id, timestamp) do
    {:ok, event_to_write} = Poison.encode build_message("MachineStarted", machine_id, timestamp)
    IO.puts(journal, event_to_write)
  end

  def set_or_reset_timer(machines, machine_id) do
    unless (machines == %{} || machines[machine_id] == nil) do
      Process.cancel_timer(machines[machine_id])
    end
    Map.put(machines, machine_id, Process.send_after(self(), {:late, machine_id}, 45_000))
  end
end
