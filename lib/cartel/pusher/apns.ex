defmodule Cartel.Pusher.Apns do
  use GenServer
  alias Cartel.Pusher.Apns
  alias Cartel.Message.Apns, as: Message
  alias Cartel.Message.Apns.Feedback

  @push_host 'gateway.push.apple.com'
  @push_sandbox_host 'gateway.sandbox.push.apple.com'
  @push_port 2195

  @feedback_host 'feedback.push.apple.com'
  @feedback_sandbox_host 'feedback.sandbox.push.apple.com'
  @feedback_port 2196

  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{type: Apns}), do: {:ok, %{socket: nil, conf: conf}}

  def send(pid, message), do: GenServer.call(pid, {:send, message})

  def feedback(pid), do: GenServer.call(pid, {:feedback})

  def handle_call({:send, message}, from, state = %{conf: conf, socket: nil}) do
    opts = [:binary, active: true, certfile: conf.cert, keyfile: conf.key,
          cacertfile: conf.cacert]
    {:ok, socket} = connect(:push, conf.env, opts)
    handle_call({:send, message}, from, %{state | socket: socket})
  end

  def handle_call({:send, message}, _from, state) do
    request = Message.serialize(message)
    :ok = :ssl.send(state.socket, request)
    {:reply, :ok, state}
  end

  def handle_call({:feedback}, _from, state = %{conf: conf}) do
    opts = [:binary, active: false, certfile: conf.cert, keyfile: conf.key,
          cacertfile: conf.cacert]
    {:ok, socket} = connect(:feedback, conf.env, opts)
    stream = Stream.resource(
      fn -> socket end,
      fn socket ->
        case  :ssl.recv(socket, Feedback.record_size) do
          {:ok, data} -> {[Feedback.deserialize(data)]}
          _ -> {:halt, socket}
        end
      end,
      fn socket -> :ssl.close(socket) end
    )
    {:reply, {:ok, stream}, state}
  end

  def handle_info({:ssl, _, msg}, state) do
    {:stop, Message.deserialize(msg), state}
  end

  def handle_info({:ssl_closed, _}, state) do
    {:stop, "Connection closed", state}
  end

  def handle_info(info, state) do
    {:stop, info, state}
  end

  defp connect(:push, :sandbox, opts) do
   :ssl.connect(@push_sandbox_host, @push_port, opts)
  end

  defp connect(:push, :production, opts) do
    :ssl.connect(@push_host, @push_port, opts)
  end

  defp connect(:feedback, :sandbox, opts) do
   :ssl.connect(@feedback_sandbox_host, @feedback_port, opts)
  end

  defp connect(:feedback, :production, opts) do
    :ssl.connect(@feedback_host, @feedback_port, opts)
  end
end
