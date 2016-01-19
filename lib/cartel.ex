defmodule Cartel do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    {:ok, dealers} = Application.fetch_env(:cartel, :dealers)
    children = Enum.map(dealers, &(worker(Cartel.Dealer, [&1], id: &1[:id])))
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
