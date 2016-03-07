defmodule Cartel.Dealer do
  use GenServer

  defp dealer_supervisor_name(id), do: :"Cartel.Dealer.Supervisor@#{id}"
  defp dealer_name(id), do: :"Cartel.Dealer@#{id}"
  defp pusher_name(id, type), do: :"Cartel.Pusher@#{id}/#{type}"

  def send(appid, type, message) do
    GenServer.call(dealer_name(appid), {:send, appid, type, message})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: dealer_name(args[:id]))
  end

  def init(args) do
    import Supervisor.Spec, warn: false
    children = args[:pushers]
    |> Enum.map(fn pusher ->
      id = pusher_name(args[:id], pusher[:type])
      worker(pusher[:type], [id, pusher], id: id)
    end)
    opts = [strategy: :one_for_one, id: dealer_supervisor_name(args[:id])]
    Supervisor.start_link(children, opts)
  end

  def handle_call({:send, appid, type, message}, _from, state) do
    {:reply, type.send(message, pusher_name(appid, type)), state}
  end
end
