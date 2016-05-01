defmodule Cartel.Pusher.Apns do
  use GenServer
  alias Cartel.Pusher.Apns
  alias Cartel.Message.Apns, as: Message

  @push_host 'gateway.push.apple.com'
  @push_sandbox_host 'gateway.sandbox.push.apple.com'
  @push_port 2195

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(conf = %{type: Apns}) do
    {:ok, %{socket: nil, conf: conf}}
  end

  def send(pid, message) do
    GenServer.call(pid, {:send, message})
  end

  defp connect(:sandbox, opts) do
   :ssl.connect(@push_sandbox_host, @push_port, opts)
  end

  defp connect(:production, opts) do
    :ssl.connect(@push_host, @push_port, opts)
  end

  def handle_call({:send, message}, from, state = %{conf: conf, socket: nil}) do
    opts = [:binary, active: true, certfile: conf.cert, keyfile: conf.key,
          cacertfile: conf.cacert]
    {:ok, socket} = connect(conf.env, opts)
    handle_call({:send, message}, from, %{state | socket: socket})
  end

  def handle_call({:send, message}, _from, state) do
    request = Message.serialize(message)
    :ok = :ssl.send(state.socket, request)
    {:reply, :ok, state}
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
end
