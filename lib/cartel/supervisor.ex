defmodule Cartel.Supervisor do
  @moduledoc """
  Supervisor for `Cartel.Dealer` processes
  """
  use Supervisor

  @doc """
  Starts the supervisor
  """
  @spec start_link([id: String.t, pushers: [%{}]]) :: Supervisor.on_start
  def start_link(dealers) do
    Supervisor.start_link(__MODULE__, dealers, name: __MODULE__)
  end

  def init(dealers) do
    dealers
    |> Enum.map(fn dealer ->
      worker(Cartel.Dealer, [dealer], id: dealer[:id])
    end)
    |> supervise([strategy: :one_for_one])
  end
end
