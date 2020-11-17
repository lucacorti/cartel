defmodule Cartel.Supervisor do
  @moduledoc """
  Cartel supervisor for dealer processes
  """
  use Supervisor

  alias Cartel.Dealer

  @doc """
  Starts the supervisor
  """
  @spec start_link :: Supervisor.on_start()
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    [supervisor(Dealer, [], restart: :permanent)]
    |> supervise(strategy: :simple_one_for_one)
  end
end
