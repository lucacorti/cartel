defmodule Cartel.Dealer do
    use GenServer

    alias Cartel.Pusher.Apns
    alias Cartel.Pusher.Gcm

    def start_link(args) do
      GenServer.start_link(__MODULE__, args, name: :"Cartel.Dealer@#{args[:id]}")
    end

    def init(args) do
      import Supervisor.Spec, warn: false
      apns = args[:pushers]
      |> Enum.filter_map(
        &(&1[:type] == :apns),
        &(worker(Cartel.Pusher.Apns, [&1], id: :"#{args[:id]}/apns"))
      )
      gcm = args[:pushers]
      |> Enum.filter_map(
        &(&1[:type] == :gcm),
        &(worker(Cartel.Pusher.Gcm, [&1], id: :"#{args[:id]}/gcm"))
      )
      children = Enum.concat(apns, gcm)
      opts = [strategy: :one_for_one, id: :"Cartel.Dealer.Supervisor@#{args[:id]}"]
      Supervisor.start_link(children, opts)
    end

    def send(appid, type, message) do
      GenServer.call(:"Cartel.Dealer@#{appid}", {:send, appid, type, message})
    end

    def handle_call({:send, appid, type = :apns, message}, _from, state) do
      pid = pick_worker(state, appid, type)
      {:reply, Apns.send(pid, message), state}
    end

    def handle_call({:send, appid, type = :gcm, message}, _from, state) do
      pid = pick_worker(state, appid, type)
      {:reply, Gcm.send(pid, message), state}
    end

    defp pick_worker(supervisor, appid, type) do
      {_, pid, _, _} = Supervisor.which_children(supervisor)
      |> Enum.find(nil, fn ({id, _, :worker, _}) -> id == :"#{appid}/#{type}" end)
      pid
    end
end
