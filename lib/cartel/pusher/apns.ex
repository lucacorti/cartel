defmodule Cartel.Pusher.Apns do
  use GenServer

  alias Cartel.Pusher.Apns.Message

  @initial_state %{socket: nil}

  @apns_push_host 'gateway.push.apple.com'
  @apns_push_sandbox_host 'gateway.sandbox.push.apple.com'
  @apns_push_port 2195
  @apns_feedback_host 'feedback.push.apple.com'
  @apns_feedback_sandbox_host 'feedback.sandbox.push.apple.com'
  @apns_feedback_port 2196

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def send(pid, message) do
    GenServer.cast(pid, {:send, message})
  end

  def init([type: :apns, env: :sandbox, cert: cert, key: key, cacert: cacert]) do
    {:ok, socket} = connect(@apns_push_sandbox_host, @apns_push_port, cert, key, cacert)
    {:ok, %{@initial_state | socket: socket}}
  end

  def init([type: :apns, env: :production, cert: cert, key: key, cacert: cacert]) do
    {:ok, socket} = connect(@apns_push_host, @apns_push_port, cert, key, cacert)
    {:ok, %{@initial_state | socket: socket}}
  end

  defp connect(host, port, cert, key, cacert) do
    opts = [:binary, certfile: cert, keyfile: key, cacertfile: cacert]
    :ssl.connect(host, port, opts)
  end

  def handle_cast({:send, message}, state) do
    request = Message.encode(message)
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
