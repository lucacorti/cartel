defmodule Cartel.Dealer do
  use Supervisor
  alias Cartel.Pusher

  defp dealer_name(id), do: :"Cartel.Dealer@#{id}"
  defp pusher_name(appid, type, env) do
    :"Cartel.Pusher@#{appid}/#{type}/#{env}"
  end

  def send(appid, type, env, message) do
    Pusher.send(pusher_name(appid, type, env), type, message)
  end

  def start_link(args) do
    opts = [id: dealer_name(args[:id]), name: dealer_name(args[:id])]
    Supervisor.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    args[:pushers]
    |> Enum.map(fn pusher ->
      pusher_id = pusher_name(args[:id], pusher[:type], pusher[:env])
      worker(Pusher, [pusher_id, pusher], id: pusher_id, name: pusher_id)
    end)
    |> supervise([strategy: :one_for_one])
  end
end
