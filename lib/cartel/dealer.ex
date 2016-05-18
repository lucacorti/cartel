defmodule Cartel.Dealer do
  @moduledoc """
  `Cartel.Dealer` OTP Supervisor for a specific `appid`
  """
  use Supervisor

  @doc """
  Starts the dealer
  """
  @spec start_link([id: String.t, pushers: [%{}]]) :: Supervisor.on_start
  def start_link(args) do
    dealer = :"#{__MODULE__}@#{args[:id]}"
    Supervisor.start_link(__MODULE__, args, id: dealer, name: dealer)
  end

  def init(args) do
    args[:pushers]
    |> Enum.map(fn pusher ->
      pusher_name = pusher[:type].name(args[:id])
      pool_options = Map.get(pusher, :pool, [size: 5, max_overflow: 10])

      pool_options = pool_options
      |> Keyword.put(:name, {:local, pusher_name})
      |> Keyword.put(:worker_module, pusher[:type])

      :poolboy.child_spec(pusher_name, pool_options, pusher)
    end)
    |> supervise(strategy: :one_for_one)
  end
end
