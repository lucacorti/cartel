defmodule Cartel.Pusher.Gcm do
  @moduledoc """
  Google GCM interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Gcm

  alias HTTPoison.Response

  @gcm_server_url "https://gcm-http.googleapis.com/gcm/send"

  @doc """
  Starts the pusher
  """
  @spec start_link(%{key: String.t}) :: GenServer.on_start
  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{}), do: {:ok, conf}

  def handle_push(pid, message, payload) do
    GenServer.call(pid, {:push, message, payload})
  end

  def handle_call({:push, _message, payload}, _from, state) do
    headers = [
      "Content-Type": "application/json",
      "Authorization": "key=#{state[:key]}"
    ]

    case HTTPoison.post(@gcm_server_url, [body: payload, headers: headers]) do
      %Response{status_code: code} when code >= 400 ->
        {:reply, {:error, :unauthorized}, state}

      %Response{body: body} ->
        case Poison.decode!(body) do
          %{"results" => [%{"message_id" => _id}]} ->
            {:reply, :ok, state}
          %{"results" => [%{"error" => error}]} ->
            {:reply, {:error, error}, state}
        end
    end
  end
end
