defmodule Cartel.Supervisor do
  @moduledoc """
  `Cartel.Supervisor` main OTP Supervisor
  """
  use Supervisor

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
