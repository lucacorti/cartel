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
    {:ok, pid, basic_headers(@push_sandbox_host)}
  end

  defp connect(conf = %{env: :production}) do
    opts = [certfile: conf.cert, keyfile: conf.key, cacertfile: conf.cacert]
    {:ok, pid} = :h2_client.start_link(:https, @push_host, 443, opts)
    {:ok, pid, basic_headers(@push_host)}
  end

  defp basic_headers(host) do
    [
      {":method", "POST"},
      {":scheme", "https"},
      {":authority", List.to_string(host)},
      {"accept", "application/json"},
      {"accept-encoding", "gzip, deflate"}
    ]
  end

  defp add_message_headers(headers, message = %Apns2{}) do
    headers
    |> add_message_priority_header(message.priority)
    |> add_message_expiration_header(message.expiration)
    |> add_message_id_header(message.id)
    |> add_message_topic_header(message.topic)
    |> add_message_path_header(message.token)
  end

  defp add_message_priority_header(headers, priority) when is_integer(priority) do
    List.insert_at(headers, 0, {":apns-priority", "#{priority}"})
  end

  defp add_message_expiration_header(headers, expiration) when is_integer(expiration) do
    List.insert_at(headers, 0, {":apns-expiration", "#{expiration}"})
  end

  defp add_message_id_header(headers, id) when is_binary(id) do
    List.insert_at(headers, 0, {":apns-id", "#{id}"})
  end

  defp add_message_id_header(headers, _), do: headers

  defp add_message_topic_header(headers, topic) when is_binary(topic) do
    List.insert_at(headers, 0, {":apns-topic", "#{topic}"})
  end

  defp add_message_topic_header(headers, _), do: headers

  defp add_message_path_header(headers, token) when is_binary(token) do
    List.insert_at(headers, 0, {":path", "/3/device/#{token}"})
  end
end
