defmodule Cartel do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    case Application.fetch_env(:cartel, :dealers) do
      {:ok, dealers} -> Cartel.Supervisor.start_link(dealers)
      _ -> Cartel.Supervisor.start_link([])
    end
  end
end
