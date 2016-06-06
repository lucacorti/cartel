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
    case HTTPotion.post(message.channel, [headers: headers, body: payload]) do
      %Response{status_code: code, headers: headers} when code >= 400 ->
        {:reply, {:error, headers.hdrs}, state}
      %Response{headers: _header} ->
        {:reply, :ok, state}
    end
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

  defp add_message_headers(message = %Wns{}, headers) do
    headers
    |> add_message_header_cache_policy(message.cache_policy)
    |> add_message_header_ttl(message.ttl)
    |> add_message_header_suppress_popup(message.suppress_popup)
    |> add_message_header_request_for_status(message.request_for_status)
  end

  defp add_message_header_cache_policy(headers, true) do
    List.insert_at(headers, 0, {"X-WNS-Cache-Policy", "cache"})
  end

  defp add_message_header_cache_policy(headers, false) do
    List.insert_at(headers, 0, {"X-WNS-Cache-Policy", "no-cache"})
  end

  defp add_message_header_cache_policy(headers, _), do: headers

  defp add_message_header_ttl(headers, ttl) when is_integer(ttl) and ttl > 0 do
    List.insert_at(headers, 0, {"X-WNS-TTL", ttl})
  end

  defp add_message_header_ttl(headers, _), do: headers

  defp add_message_header_suppress_popup(headers, suppress_popup)
  when is_boolean(suppress_popup) and suppress_popup == true do
    List.insert_at(headers, 0, {"X-WNS-SuppressPopup", "true"})
  end

  defp add_message_header_suppress_popup(headers, _), do: headers

  defp add_message_header_request_for_status(headers, request_for_status)
  when is_boolean(request_for_status) and request_for_status == true do
    List.insert_at(headers, 0, {"X-WNS-RequestForStatus", "true"}) ++ headers
  end

  defp add_message_header_request_for_status(headers, _), do: headers
end
