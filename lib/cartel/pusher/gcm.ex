defmodule Cartel.Pusher.Gcm do
  use GenServer

  alias Cartel.Pusher.Gcm.Message

  @gcm_server_url "https://gcm-http.googleapis.com/gcm/send"

  def start_link(id, args) do
    GenServer.start_link(__MODULE__, args, name: id)
  end

  def send(pid, message) do
    GenServer.call(pid, {:send, message})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:send, message}, _from, state) do
    {:ok, request} = Message.encode(message)
    headers = ["Content-Type": "application/json", "Authorization": "key=" <> state[:key]]
    response = HTTPotion.post(@gcm_server_url, [body: request, headers: headers])
    if response.status_code >= 400 do
      {:stop, response.status_code, state}
    else
      {:reply, {:ok, response.status_code, Poison.decode(response.body)}, state}
    end
  end
end
