defmodule MinimalServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      MinimalServer.Endpoint,
      Stack, # The same as {Stack, []}
      MinimalServer.Machine
      # Starts a worker by calling: MinimalServer.Worker.start_link(arg)
      # {MinimalServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MinimalServer.Supervisor]
    # ok now that I have 2 children, what's making one fail?
    IO.puts "#{__MODULE__} starting, getting up the children"
    IO.inspect children
    Supervisor.start_link(children, opts)
  end
end
