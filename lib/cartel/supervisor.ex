defmodule Cartel.Supervisor do
  @moduledoc """
  Internal supervisor for dealer processes
  """
  use Supervisor

  @doc """
  Starts the supervisor
  """
  @spec start_link(%{String.t => %{}}) :: Supervisor.on_start
  def start_link(dealers) do
    Supervisor.start_link(__MODULE__, dealers, name: __MODULE__)
  end

  def init(dealers) do
    dealers
    |> Enum.map(fn {appid, pushers} ->
      worker(Cartel.Dealer, [[id: appid, pushers: pushers]], id: appid)
    end)
    |> supervise([strategy: :one_for_one])
  end
end
