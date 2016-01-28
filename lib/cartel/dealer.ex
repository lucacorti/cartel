defmodule Cartel.Dealer do
  use GenServer

  alias Cartel.Pusher.{Apns, Gcm}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :"Cartel.Dealer@#{args[:id]}")
  end

  def send(appid, type, message) do
    GenServer.call(:"Cartel.Dealer@#{appid}", {:send, appid, type, message})
  end

  def init(args) do
    import Supervisor.Spec, warn: false
    children = args[:pushers]
    |> Enum.map(fn pusher ->
      id = make_name(args[:id], pusher[:type])
      case pusher[:type] do
        :apns -> worker(Apns, [id, pusher], id: id)
        :gcm -> worker(Gcm, [id, pusher], id: id)
      end
    end)
    opts = [strategy: :one_for_one, id: :"Cartel.Dealer.Supervisor@#{args[:id]}"]
    Supervisor.start_link(children, opts)
  end

  def handle_call({:send, appid, type = :apns, message}, _from, state) do
    pid = GenServer.whereis(make_name(appid, type))
    {:reply, Apns.send(pid, message), state}
  end

  def handle_call({:send, appid, type = :gcm, message}, _from, state) do
    pid = GenServer.whereis(make_name(appid, type))
    {:reply, Gcm.send(pid, message), state}
  end

  defp make_name(id, type) do
    :"Cartel.Pusher@#{id}/#{type}"
  end
end
