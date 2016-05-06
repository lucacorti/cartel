defmodule Cartel.Supervisor do
  @moduledoc """
  `Cartel.Supervisor` main OTP Supervisor
  """
  use Supervisor

  def start_link(dealers) do
    Supervisor.start_link(__MODULE__, dealers)
  end

  def init(dealers) do
    dealers
    |> Enum.map(fn dealer ->
      worker(Cartel.Dealer, [dealer], id: dealer[:id], name: dealer[:name])
    end)
    |> supervise([strategy: :one_for_one])
  end
end
