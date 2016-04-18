defmodule Cartel.Pusher.Apns2 do
  use GenServer
  alias Cartel.Pusher.Apns2
  alias Cartel.Message.Apns2, as: Message

  @push_host 'api.push.apple.com'
  @push_sandbox_host 'api.development.push.apple.com'

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(conf = %{type: Apns2}) do
    {:ok, %{conf: conf, headers: nil, pid: nil}}
  end

  defp connect(conf = %{env: :sandbox}) do
    opts = [certfile: conf.cert, keyfile: conf.key, cacertfile: conf.cacert]
    {:ok, pid} = :http2_client.start_link(:https, @push_sandbox_host, 443, opts)
    {:ok, pid, add_basic_headers(@push_sandbox_host)}
  end

  defp connect(conf = %{env: :production}) do
    opts = [certfile: conf.cert, keyfile: conf.key, cacertfile: conf.cacert]
    {:ok, pid} = :http2_client.start_link(:https, @push_host, 443, opts)
    {:ok, pid, add_basic_headers(@push_host)}
  end

  defp add_basic_headers(host) do
    [
      {":method", "POST"},
      {":scheme", "https"},
      {":authority", List.to_string(host)},
      {"accept", "application/json"},
      {"accept-encoding", "gzip, deflate"}
    ]
  end

  defp add_message_required_headers(headers, message) do
    headers ++ [{":path", "/3/device/#{message.token}"},
      {":apns-expiration", "#{message.expiration}"},
      {":apns-priority", "#{message.priority}"}
    ]
  end

  defp add_message_headers(headers, message = %Message{id: nil, topic: nil}) do
    add_message_required_headers(headers, message)
  end

  defp add_message_headers(headers, message = %Message{id: id, topic: nil}) do
    [{":apns-id", "#{id}"} | add_message_required_headers(message, headers)]
  end

  defp add_message_headers(headers, message = %Message{id: nil, topic: topic}) do
    [{":apns-topic", "#{topic}"} | add_message_required_headers(message, headers)]
  end

  defp add_message_headers(headers, message = %Message{id: id, topic: topic}) do
    add_message_required_headers(message, headers) ++ [
      {":apns-id", "#{id}"},
      {":apns-topic", "#{topic}"}
    ]
  end

  def send(pid, message) do
    GenServer.call(pid, {:send, message})
  end

  def handle_call({:send, message}, from, state = %{pid: nil, headers: nil}) do
    {:ok, pid, headers} = connect(state.conf)
    handle_call({:send, message}, from, %{state | pid: pid, headers: headers})
  end

  def handle_call({:send, message}, _from, state) do
    {:ok, {res_headers, res_body}} = :http2_client.sync_request(state.pid,
      add_message_headers(state.headers, message),
      Message.serialize(message))
    respond(res_headers, res_body, state)
  end

  defp respond(%{code: code}, body, state) when code >= 400 do
    {:stop, {code, Poison.decode(body)}, state}
  end

  defp respond(%{code: code}, body, state) do
    {:reply, {:ok, code, Poison.decode(body)}, state}
  end
end
