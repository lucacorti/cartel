defmodule Cartel.Pusher.Apns do
  use GenServer
  alias Cartel.Pusher.Apns
  alias Cartel.Pusher.Apns.Message

  @initial_state %{socket: nil}
  @push_host 'gateway.push.apple.com'
  @push_sandbox_host 'gateway.sandbox.push.apple.com'
  @push_port 2195
  @feedback_host 'feedback.push.apple.com'
  @feedback_sandbox_host 'feedback.sandbox.push.apple.com'
  @feedback_port 2196

  def send(pid, message) do
    GenServer.cast(pid, {:send, message})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init([type: Apns, env: :sandbox, cert: cert, key: key, cacert: cacert]) do
    {:ok, socket} = connect(@push_sandbox_host, @push_port, cert, key, cacert)
    {:ok, %{@initial_state | socket: socket}}
  end

  def init([type: Apns, env: :production, cert: cert, key: key, cacert: cacert])
  do
    {:ok, socket} = connect(@push_host, @push_port, cert, key, cacert)
    {:ok, %{@initial_state | socket: socket}}
  end

  defp connect(host, port, cert, key, cacert) do
    opts = [:binary, active: true, certfile: cert, keyfile: key,
            cacertfile: cacert]
    :ssl.connect(host, port, opts)
  end

  def handle_cast({:send, message}, state) do
    request = Message.serialize(message)
    :ok = :ssl.send(state.socket, request)
    {:noreply, state}
  end

  def handle_info(info, state) do
    case info do
      {:ssl, _, msg} -> {:stop, Message.deserialize(msg), state}
      {:ssl_closed, _} -> {:stop, "Connection closed", state}
      _ -> {:stop, info, state}
    end
  end
end
