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
  @spec start_link([type: __MODULE__, env: :production | :sandbox,
  cert: String.t, key: String.t, cacert: String.t]) :: GenServer.on_start
  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{type: __MODULE__}) do
    {:ok, %{conf: conf, headers: nil, pid: nil}}
  end

  @doc """
  Sends the message via the specified worker process
  """
  @spec push(pid, Apns2.t) :: :ok | :error
  def push(process, message), do: GenServer.call(process, {:push, message})

  def handle_call({:push, message}, from, state = %{pid: nil, headers: nil}) do
    {:ok, pid, headers} = connect(state.conf)
    handle_call({:push, message}, from, %{state | pid: pid, headers: headers})
  end

  def handle_call({:push, message}, _from, state) do
    {:ok, _} = :h2_client.send_request(state.pid,
      add_message_headers(state.headers, message),
      Message.serialize(message))
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
