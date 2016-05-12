defmodule Cartel.Pusher.Wns do
  @moduledoc """
  WNS legacy binary interface worker
  """

  use GenServer
  alias Cartel.Message

  @wns_login_url "https://login.live.com/accesstoken.srf"
  @wns_server_url "https://cloud.notify.windows.com"

  @doc """
  Sends the message via the specified worker process
  """
  def send(pid, message) do
    GenServer.cast(pid, {:send, message})
  end

  def start_link(id, args) do
    GenServer.start_link(__MODULE__, args, name: id)
  end

  def init(state) do
    {:ok, %{conf: state, token: nil}}
  end

  defp login(id, conf) do
    query = [
      "grant_type": "client_credentials",
      "client_id": id,
      "client_secret": conf.client_secret,
      "scope": "notify.windows.com"
    ]
    res = HTTPotion.post(@wns_login_url, [query: query])
    login_response(res)
  end

  defp login_response(res = %HTTPotion.Response{status_code: code})
  when code >= 400 do
    {:error, res.status_code}
  end

  defp login_response(res = %HTTPotion.Response{}) do
    {:ok, body} = Poison.decode(res.body)
    {:ok, body[:access_token]}
  end

  def handle_call({:send, message}, from, state = %{token: nil}) do
      {:ok, token} = login(state.id, state.conf)
      handle_call({:send, message}, from, %{state | token: token})
  end

  def handle_call({:send, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    query = ["token": state[:token]]
    headers = ["Content-Type": "text/xml"]
    res = HTTPotion.post(@wns_login_url, [body: request, headers: headers,
                        query: query])
    send_response(res, state)
  end

  defp send_response(res = %HTTPotion.Response{status_code: code}, state)
  when code >= 400 do
    {:stop, res.code, state}
  end

  defp send_response(res = %HTTPotion.Response{}, state) do
    {:reply, {:ok, res.status_code, Poison.decode!(res.body)}, state}
  end
end
