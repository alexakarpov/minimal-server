defmodule MinimalServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      MinimalServer.API,
      MinimalServer.Machine
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MinimalServer.Supervisor]
    IO.puts "#{__MODULE__} starting, getting up the children: " <> inspect children
    IO.inspect children
    Supervisor.start_link(children, opts)
  end
end
