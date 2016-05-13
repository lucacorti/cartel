defmodule Cartel.Dealer do
  @moduledoc """
  `Cartel.Dealer` OTP Supervisor for a specific `appid`
  """

  use Supervisor

  alias Cartel.Pusher

  def start_link(args) do
    dealer = dealer_name(args[:id])
    Supervisor.start_link(__MODULE__, args, id: dealer, name: dealer)
  end

  def init(args) do
    args[:pushers]
    |> Enum.map(fn pusher ->
      id = Pusher.name(args[:id], pusher[:type])
      worker(Pusher, [[id: args[:id], pusher: pusher]], id: id, name: id)
    end)
    |> supervise([strategy: :one_for_one])
  end

  defp dealer_name(id), do: :"#{__MODULE__}@#{id}"
end
