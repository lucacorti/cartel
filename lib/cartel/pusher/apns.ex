defmodule Cartel.Pusher.Apns do
  use GenServer
  alias Cartel.Pusher.Apns.Message

  @behaviour Cartel.Pusher

  @initial_state %{socket: nil}
  @apns_push_host 'gateway.push.apple.com'
  @apns_push_sandbox_host 'gateway.sandbox.push.apple.com'
  @apns_push_port 2195
  @apns_feedback_host 'feedback.push.apple.com'
  @apns_feedback_sandbox_host 'feedback.sandbox.push.apple.com'
  @apns_feedback_port 2196

  def send(message, pname) do
    GenServer.cast(pname, {:send, message})
  end

  def start_link(id, args) do
    GenServer.start_link(__MODULE__, args, name: id)
  end

  def init([type: Cartel.Pusher.Apns, env: :sandbox, cert: cert, key: key, cacert: cacert]) do
    {:ok, socket} = connect(@apns_push_sandbox_host, @apns_push_port, cert, key, cacert)
    {:ok, %{@initial_state | socket: socket}}
  end

  def init([type: Cartel.Pusher.Apns, env: :production, cert: cert, key: key, cacert: cacert]) do
    {:ok, socket} = connect(@apns_push_host, @apns_push_port, cert, key, cacert)
    {:ok, %{@initial_state | socket: socket}}
  end

  defp connect(host, port, cert, key, cacert) do
    opts = [:binary, active: true, certfile: cert, keyfile: key, cacertfile: cacert]
    :ssl.connect(host, port, opts)
  end

  def handle_cast({:send, message}, state) do
    request = Message.serialize(message)
    :ok = :ssl.send(state.socket, request)
    {:noreply, state}
  end

  def handle_info(info, state) do
    case info do
      {:ssl, _, msg} -> {:stop, Message.decode(msg), state}
      {:ssl_closed, _} -> {:stop, "Connection closed", state}
      _ -> {:stop, info, state}
    end
  end
end
