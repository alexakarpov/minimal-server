defmodule Machine.Helper.Tests do
  use ExUnit.Case
  import Mock

  test "message is built" do
    assert Machine.Helper.build_message("FooType", 42, "2018-something") == %{
      :type => "FooType",
      :machine_id => 42,
      :event_time => "2018-something"}
  end

  test "message is stamped" do
    with_mock Timex, [format: fn(_,_,_) -> {:ok, "2018-01-19-lalala"} end,
                      now: fn() -> :mock end] do
      assert Machine.Helper.stamp(Machine.Helper.build_message("FooType", 42, "2018-something")) == %{
        type: "FooType",
        machine_id: 42,
        event_time: "2018-something",
        recorded_at: "2018-01-19-lalala"}
    end
  end

  test "CycleComplete messages are recorded" do
    with_mocks([{Timex,
                 [],
                 [format: fn(_,_,_) -> {:ok, "2018-lalala"} end,
                  now: fn() -> :mock end]},
                {Kaffe.Producer,
                 [],
                 [produce_sync: fn(_,_) -> :ok end]}]) do
      message = %{machine_id: 12,
                  timestamp: "2018-01-01T11:22:33Z",
                  type: "CycleComplete"}
      {:ok, journal} = File.open("/tmp/journal.log", [:write, :read])
      Machine.Helper.record_cycle_complete(journal, message)
      {:ok, txt} = File.read("/tmp/journal.log")
      assert txt == "{\"type\":\"MachineCycled\",\"recorded_at\":\"2018-lalala\",\"machine_id\":12,\"event_time\":\"2018-01-01T11:22:33Z\"}\n"
      on_exit(fn -> File.rm("/tmp/journal.txt") end)
    end
  end

end
