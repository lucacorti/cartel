defmodule Cartel.Pusher.Wns do
  @moduledoc """
  Microsoft WNS interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Wns

  alias Cartel.Message.Wns
  alias HTTPotion.Response

  @wns_login_url "https://login.live.com/accesstoken.srf"

  @doc """
  Starts the pusher
  """
  @spec start_link(%{sid: String.t, secret: String.t}) :: GenServer.on_start
  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def init(conf = %{}), do: {:ok, %{conf: conf, token: nil}}

  @doc """
  Sends the message via the specified worker process
  """
  @spec push(pid, Wns.t) :: :ok | :error
  def push(pid, message), do: GenServer.call(pid, {:push, message})

  def handle_call({:push, message}, from, state = %{token: nil}) do
      {:ok, token} = login(state.conf.sid, state.conf.secret)
      handle_call({:push, message}, from, %{state | token: token})
  end

  def handle_call({:push, message}, _from, state) do
    headers = [
      "Content-Type": Wns.content_type(message),
      "Authorization": "Bearer #{state.token}",
      "X-WNS-Type": message.type
    ]

    if is_boolean(message.cache_policy) && message.cache_policy do
      headers = ["X-WNS-Cache-Policy": "cache"] ++ headers
    end

    if String.valid?(message.tag) && String.length(message.tag) > 0 do
      headers = ["X-WNS-Tag": message.tag] ++ headers
    end

    if String.valid?(message.group) && String.length(message.group) > 0 do
      headers = ["X-WNS-Group": message.group] ++ headers
    end

    if is_integer(message.ttl) and message.ttl > 0 do
      headers = ["X-WNS-TTL": message.ttl] ++ headers
    end

    if is_boolean(message.suppress_popup) && message.suppress_popup do
      headers = ["X-WNS-SuppressPopup": "true"] ++ headers
    end

    if is_boolean(message.request_for_status) && message.request_for_status do
      headers = ["X-WNS-RequestForStatus": "true"] ++ headers
    end

    body = Message.serialize(message)
    res = HTTPotion.post(message.channel, [headers: headers, body: body])
    send_response(res, state)
  end

  defp send_response(%Response{status_code: code, headers: headers}, state)
  when code >= 400 do
    {:reply, {:error, headers.hdrs}, state}
  end

  defp send_response(%Response{headers: headers}, state) do
    {:reply, {:ok, headers.hdrs}, state}
  end

  defp login(client_id, client_secret) do
    gt = URI.encode_www_form("client_credentials")
    sc = URI.encode_www_form("notify.windows.com")
    cid = URI.encode_www_form(client_id)
    cs = URI.encode_www_form(client_secret)
    body = "grant_type=#{gt}&scope=#{sc}&client_id=#{cid}&client_secret=#{cs}"
    headers = ["Content-Type": "application/x-www-form-urlencoded"]

    res = HTTPotion.post(@wns_login_url, [headers: headers, body: body])
    {:ok, Poison.decode!(res.body)["access_token"]}
  end
end
