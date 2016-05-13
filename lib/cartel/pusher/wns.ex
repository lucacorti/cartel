defmodule Cartel.Pusher.Wns do
  @moduledoc """
  WNS interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Wns

  alias Cartel.Message.Wns
  alias HTTPotion.Response

  @wns_login_url "https://login.live.com/accesstoken.srf"
  @wns_server_url "https://cloud.notify.windows.com"

  def start_link(id, args), do: GenServer.start_link(__MODULE__, args, name: id)

  def init(conf = %{type: __MODULE__}), do: {:ok, %{conf: conf, token: nil}}

  @doc """
  Sends the message via the specified worker process
  """
  @spec push(pid, Wns.t) :: :ok | :error
  def push(pid, message), do: GenServer.cast(pid, {:push, message})

  def handle_call({:push, message}, from, state = %{token: nil}) do
      {:ok, token} = login(state.id, state.conf)
      handle_call({:push, message}, from, %{state | token: token})
  end

  def handle_call({:push, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    query = ["token": state[:token]]
    headers = ["Content-Type": "text/xml"]
    res = HTTPotion.post(@wns_login_url, [body: request, headers: headers,
                        query: query])
    send_response(res, state)
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

  defp login_response(%Response{status_code: code}) when code >= 400 do
    {:error, code}
  end

  defp login_response(%Response{body: body}) do
    {:ok, body} = Poison.decode(body)
    {:ok, body[:access_token]}
  end

  defp send_response(%Response{status_code: code}, state) when code >= 400 do
    {:stop, code, state}
  end

  defp send_response(%Response{status_code: code, body: body}, state) do
    {:reply, {:ok, code, Poison.decode!(body)}, state}
  end
end
