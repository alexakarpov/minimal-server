defmodule Stack do
  use GenServer

  # Callbacks

  @impl true
  def init(stack) do
    IO.puts "#{__MODULE__} is being initialized"
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end

  # Client

  def start_link(default) when is_list(default) do
    IO.puts "#{__MODULE__}'s own bootstrap; calling GenServer.start_link/2"
    GenServer.start_link(__MODULE__, default)
  end

  def push(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

end

# # Start the server
# {:ok, pid} = GenServer.start_link(Stack, [:hello])

# # This is the client
# GenServer.call(pid, :pop)
# #=> :hello

# GenServer.cast(pid, {:push, :world})
# #=> :ok

# GenServer.call(pid, :pop)
# #=> :world
