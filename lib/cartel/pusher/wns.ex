defmodule Cartel.Pusher.Wns do
  use GenServer
  alias Cartel.Message.Wns, as: Message

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
    res = HTTPotion.post(@wns_login_url, [query: query])
    login_respond(res, state)
  end

  defp login_respond(res = %HTTPotion.Response{status_code: code}, state)
  when code >= 400 do
      {:stop, res.status_code, state}
  end

  defp login_respond(res = %HTTPotion.Response{}, state) do
    {:ok, [[token: Poison.decode(response.body)[:access_token]] | state]}
  end

  def handle_call({:send, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    query = ["token": state[:token]]
    headers = ["Content-Type": "text/xml"]
    res = HTTPotion.post(@wns_login_url, [body: request, headers: headers,
                        query: query])
    send_respond(res, state)
  end

  defp send_respond(res = %HTTPotion.Response{status_code: code}, state)
  when code >= 400 do
    {:stop, res.code, state}
  end

  defp send_respond(res = %HTTPotion.Response{}, state) do
    {:reply, {:ok, res.status_code, Message.deserialize(res.body)}, state}
  end
end
