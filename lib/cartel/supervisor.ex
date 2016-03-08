defmodule Cartel.Supervisor do
  use Supervisor

  def start_link(dealers) do
    Supervisor.start_link(__MODULE__, dealers)
  end

  def init(dealers) do
    dealers
    |> Enum.map(&(worker(Cartel.Dealer, [&1], id: &1[:id], name: &1[:id])))
    |> supervise([strategy: :one_for_one])
  end
end
