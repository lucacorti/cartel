defmodule Cartel.Pusher.Apns do
  @moduledoc """
  APNS Binary API worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Apns

  alias Cartel.Message.Apns
  alias Cartel.Message.Apns.Feedback

  @push_host 'gateway.push.apple.com'
  @push_sandbox_host 'gateway.sandbox.push.apple.com'
  @push_port 2195

  @feedback_host 'feedback.push.apple.com'
  @feedback_sandbox_host 'feedback.sandbox.push.apple.com'
  @feedback_port 2196

  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{type: __MODULE__}) do
    {:ok, %{socket: nil, conf: conf}}
  end

  @doc """
  Sends the message via the specified worker process
  """
  @spec push(pid, Apns.t) :: :ok | :error
  def push(process, message), do: GenServer.call(process, {:push, message})

  @doc """
  Method to fetch `Cartel.Message.Apns.Feedback.t` records from feedback service

  Returns an Enumerable `Stream` of `Cartel.Message.Apns.Feedback` structs.
  """
  @spec feedback(String.t) :: {:ok, Stream.t}
  def feedback(appid) do
    :poolboy.transaction(Pusher.name(appid, __MODULE__), fn
      worker -> GenServer.call(worker, {:feedback})
    end)
  end

  def handle_call({:push, message}, from, state = %{conf: conf, socket: nil}) do
    opts = [:binary, active: true, certfile: conf.cert, keyfile: conf.key,
          cacertfile: conf.cacert]
    {:ok, socket} = connect(:push, conf.env, opts)
    handle_call({:push, message}, from, %{state | socket: socket})
  end

  def handle_call({:push, message}, _from, state) do
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
          {:ok, data} ->
            Feedback.decode!(data)
          _ ->
            {:halt, socket}
        end
      end,
      fn socket -> :ssl.close(socket) end
    )
    {:reply, {:ok, stream}, state}
  end

  def handle_info({:ssl, _, data}, state) do
    case data do
      <<8::size(8), status::size(8), identifier::size(32)>> ->
        {:stop, {:error, identifier, status, status_to_string(status)}, state}
      _ ->
        {:stop, {:error, :unknown}, state}
    end
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

  @no_errors 0
  @processing_error 1
  @missing_token 2
  @missing_topic 3
  @missing_payload 4
  @invalid_token_size 5
  @invalid_topic_size 6
  @invalid_payload_size 7
  @invalid_token 8
  @shutdown 10
  @unknown_error 255

  defp status_to_string(@no_errors), do: "No errors encountered"
  defp status_to_string(@processing_error), do: "Processing error"
  defp status_to_string(@missing_token), do: "Missing device token"
  defp status_to_string(@missing_topic), do: "Missing topic"
  defp status_to_string(@missing_payload), do: "Missing payload"
  defp status_to_string(@invalid_token_size), do: "Invalid token size"
  defp status_to_string(@invalid_topic_size), do: "Invalid topic size"
  defp status_to_string(@invalid_payload_size), do: "Invalid payload_size"
  defp status_to_string(@invalid_token), do: "Invalid token"
  defp status_to_string(@shutdown), do: "Shutdown"
  defp status_to_string(_), do: "None (unknown)"
end
