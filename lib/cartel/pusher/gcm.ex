defmodule Cartel.Pusher.Gcm do
  @moduledoc """
  GCM interface worker
  """

  use GenServer
  alias Cartel.Message

  @gcm_server_url "https://gcm-http.googleapis.com/gcm/send"

  @doc """
  Sends the message via the specified worker process
  """
  def send(pid, message) do
    GenServer.call(pid, {:send, message})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:send, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    headers = [
      "Content-Type": "application/json",
      "Authorization": "key=" <> state[:key]
    ]
    res = HTTPotion.post(@gcm_server_url, [body: request, headers: headers])
    respond(res, state)
  end

  defp respond(res = %HTTPotion.Response{status_code: code}, state)
  when code >= 400 do
    {:stop, res.code, state}
  end

  defp respond(res = %HTTPotion.Response{}, state) do
    {:reply, {:ok, res.status_code, Poison.decode(res.body)}, state}
  end
end
