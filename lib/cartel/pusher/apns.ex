defmodule Cartel.Pusher.Apns do
  @moduledoc """
  Apple APNS Provider API worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Apns

  alias Cartel.HTTP
  alias Cartel.Message.Apns
  alias HTTP.{Request, Response}

  @production_url "https://api.push.apple.com"
  @sandbox_url "https://api.development.push.apple.com"

  @doc """
  Starts the pusher
  """
  @spec start_link(%{
          env: :production | :sandbox,
          cert: String.t(),
          key: String.t(),
          cacert: String.t()
        }) :: GenServer.on_start()
  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  @impl Cartel.Pusher
  def handle_push(process, message, payload) do
    GenServer.call(process, {:push, message, payload})
  end

  @impl GenServer
  def init(conf), do: {:ok, %{conf: conf, headers: nil, pid: nil}}

  @impl GenServer
  def handle_call({:push, message, payload}, from, %{pid: nil, headers: nil, conf: conf} = state) do
    {:ok, pid, url} = connect(conf)
    handle_call({:push, message, payload}, from, %{state | pid: pid, url: url})
  end

  def handle_call({:push, message, payload}, _from, %{url: url} = state) do
    headers = message_headers(message)

    request =
      url
      |> Request.new("POST")
      |> Request.set_body(payload)
      |> Request.set_headers(headers)
      |> Request.put_header({"accept", "application/json"})
      |> Request.put_header({"accept-encoding", "gzip, deflate"})

    case HTTP.request(%HTTP{}, request) do
      {:ok, _, %Response{status: code}} when code >= 400 ->
        {:reply, {:error, :unauthorized}, state}

      {:ok, _, %Response{body: body}} ->
        case Jason.decode!(body) do
          %{"results" => [%{"message_id" => _id}]} ->
            {:reply, :ok, state}

          %{"results" => [%{"error" => error}]} ->
            {:reply, {:error, error}, state}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp connect(%{env: :sandbox, cert: cert, key: key, cacert: cacert}) do
    {:ok, pid} = HTTP.connect(@sandbox_url, certfile: cert, keyfile: key, cacertfile: cacert)
    {:ok, pid, @sandbox_url}
  end

  defp connect(%{env: :production, cert: cert, key: key, cacert: cacert}) do
    {:ok, pid} = HTTP.connect(@production_url, certfile: cert, keyfile: key, cacertfile: cacert)
    {:ok, pid, @production_url}
  end

  defp message_headers(message) do
    []
    |> add_message_priority_header(message)
    |> add_message_expiration_header(message)
    |> add_message_id_header(message)
    |> add_message_topic_header(message)
    |> add_message_path_header(message)
  end

  defp add_message_priority_header(headers, %Apns{priority: priority})
       when is_integer(priority) do
    [{":apns-priority", "#{priority}"} | headers]
  end

  defp add_message_expiration_header(headers, %Apns{expiration: expiration})
       when is_integer(expiration) do
    [{":apns-expiration", "#{expiration}"} | headers]
  end

  defp add_message_id_header(headers, %Apns{id: id}) when is_binary(id) do
    [{":apns-id", "#{id}"} | headers]
  end

  defp add_message_id_header(headers, _), do: headers

  defp add_message_topic_header(headers, %Apns{topic: topic}) when is_binary(topic) do
    [{":apns-topic", "#{topic}"} | headers]
  end

  defp add_message_topic_header(headers, _), do: headers

  defp add_message_path_header(headers, %Apns{token: token}) when is_binary(token) do
    [{":path", "/3/device/#{token}"} | headers]
  end
end
