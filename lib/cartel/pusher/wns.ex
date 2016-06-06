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

  def handle_push(pid, message, payload) do
    GenServer.call(pid, {:push, message, payload})
  end

  def handle_call({:push, message, payload}, from, state = %{token: nil}) do
      {:ok, token} = login(state.conf.sid, state.conf.secret)
      handle_call({:push, message, payload}, from, %{state | token: token})
  end

  def handle_call({:push, message, payload}, _from, state) do
    headers = add_message_headers(message, [
      "Content-Type": Wns.content_type(message),
      "Authorization": "Bearer #{state.token}",
      "X-WNS-Type": message.type
    ])
    res = HTTPotion.post(message.channel, [headers: headers, body: payload])
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

  defp add_message_headers(msg = %Wns{}, headers) do
    headers = add_message_header_cache_policy(msg.cache_policy, headers)
    headers = add_message_header_ttl(msg.ttl, headers)
    headers = add_message_header_suppress_popup(msg.suppress_popup, headers)
    headers = add_message_header_status(msg.request_for_status, headers)

    headers
  end

  defp add_message_header_cache_policy(true, headers) do
    ["X-WNS-Cache-Policy": "cache"] ++ headers
  end

  defp add_message_header_cache_policy(false, headers) do
    ["X-WNS-Cache-Policy": "no-cache"] ++ headers
  end

  defp add_message_header_cache_policy(_, headers), do: headers

  defp add_message_header_ttl(ttl, headers) when is_integer(ttl) and ttl > 0 do
    ["X-WNS-TTL": ttl] ++ headers
  end

  defp add_message_header_ttl(_, headers), do: headers

  defp add_message_header_suppress_popup(suppress_popup, headers)
  when is_boolean(suppress_popup) and suppress_popup do
    ["X-WNS-SuppressPopup": "true"] ++ headers
  end

  defp add_message_header_suppress_popup(_, headers), do: headers

  defp add_message_header_status(request_for_status, headers)
  when is_boolean(request_for_status) and request_for_status do
    ["X-WNS-RequestForStatus": "true"] ++ headers
  end

  defp add_message_header_status(_, headers), do: headers
end
