defmodule Cartel.Pusher.Apns2 do
  @moduledoc """
  Apple APNS Provider API worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Apns2

  alias Cartel.Message.Apns2

  @push_host 'api.push.apple.com'
  @push_sandbox_host 'api.development.push.apple.com'

  @doc """
  Starts the pusher
  """
  @spec start_link(%{env: :production | :sandbox,
  cert: String.t, key: String.t, cacert: String.t}) :: GenServer.on_start
  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{}) do
    {:ok, %{conf: conf, headers: nil, pid: nil}}
  end

  def handle_push(process, message, payload) do
    GenServer.call(process, {:push, message, payload})
  end

  def handle_call({:push, message, payload}, from, state = %{pid: nil, headers: nil}) do
    {:ok, pid, headers} = connect(state.conf)
    handle_call({:push, message, payload}, from, %{state | pid: pid, headers: headers})
  end

  def handle_call({:push, message, payload}, _from, state) do
    headers = add_message_headers(state.headers, message)
    {:ok, _} = :h2_client.send_request(state.pid, headers, payload)
    {:reply, :ok, state}
  end

  defp connect(conf = %{env: :sandbox}) do
    opts = [certfile: conf.cert, keyfile: conf.key, cacertfile: conf.cacert]
    {:ok, pid} = :h2_client.start_link(:https, @push_sandbox_host, 443, opts)
    {:ok, pid, add_basic_headers(@push_sandbox_host)}
  end

  defp connect(conf = %{env: :production}) do
    opts = [certfile: conf.cert, keyfile: conf.key, cacertfile: conf.cacert]
    {:ok, pid} = :h2_client.start_link(:https, @push_host, 443, opts)
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

  defp add_message_required_headers(headers, msg) do
    headers ++ [{":path", "/3/device/#{msg.token}"},
      {":apns-expiration", "#{msg.expiration}"},
      {":apns-priority", "#{msg.priority}"}
    ]
  end

  defp add_message_headers(headers, msg = %Apns2{id: nil, topic: nil}) do
    add_message_required_headers(headers, msg)
  end

  defp add_message_headers(headers, msg = %Apns2{id: id, topic: nil}) do
    [{":apns-id", "#{id}"} | add_message_required_headers(msg, headers)]
  end

  defp add_message_headers(headers, msg = %Apns2{id: nil, topic: topic})
  do
    [{":apns-topic", "#{topic}"} | add_message_required_headers(msg, headers)]
  end

  defp add_message_headers(headers, msg = %Apns2{id: id, topic: topic})
  do
    add_message_required_headers(msg, headers) ++ [
      {":apns-id", "#{id}"},
      {":apns-topic", "#{topic}"}
    ]
  end
end
