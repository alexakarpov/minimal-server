defmodule MinimalServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  
  def start(_type, _args) do
    IO.puts "Application start, now that children are up."
    # List all child processes to be supervised
    children = [
      MinimalServer.Endpoint
      # Starts a worker by calling: MinimalServer.Worker.start_link(arg)
      # {MinimalServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MinimalServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
