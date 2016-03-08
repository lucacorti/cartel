defmodule Cartel do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    dealers = Application.fetch_env!(:cartel, :dealers)
    dealers
    |> Enum.map(&(worker(Cartel.Dealer, [&1], id: &1[:id], name: &1[:id])))
    |> Supervisor.start_link([strategy: :one_for_one, name: Cartel.Supervisor])
  end
end
