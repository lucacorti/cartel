defmodule Cartel.Pusher.Wns do
  use GenServer
  alias Cartel.Pusher.Wns.Message

  @wns_login_url "https://login.live.com/accesstoken.srf"
  @wns_server_url "https://cloud.notify.windows.com"

  def send(pid, message) do
    GenServer.cast(pid, {:send, message})
  end

  def start_link(id, args) do
    GenServer.start_link(__MODULE__, args, name: id)
  end

  def init(state) do
    query = [
      "grant_type": "client_credentials",
      "client_id": state[:id],
      "client_secret": state[:client_secret],
      "scope": "notify.windows.com"
    ]
    response = HTTPotion.post(@wns_login_url, [query: query])
    if response.status_code >= 400 do
      {:stop, response.status_code, state}
    else
      {:ok, [[token: Poison.decode(response.body)[:access_token]] | state]}
    end
  end

  def handle_call({:send, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    query = [
      "token": state[:token]
    ]
    headers = [
      "Content-Type": "text/xml"
    ]
    response = HTTPotion.post(@wns_login_url, [
      body: request, headers: headers, query: query
    ])
    if response.status_code >= 400 do
      {:stop, response.status_code, state}
    else
      {:reply, {:ok, response.status_code, Message.deserialize(response.body)}, state}
    end
  end
end
