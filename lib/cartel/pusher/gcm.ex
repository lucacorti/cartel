defmodule Cartel.Pusher.Gcm do
  @moduledoc """
  Google GCM interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Gcm

  alias Cartel.Message.Gcm

  @gcm_server_url "https://gcm-http.googleapis.com/gcm/send"

  @doc """
  Starts the pusher
  """
  @spec start_link([type: __MODULE__, key: String.t]) :: GenServer.on_start
  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{type: __MODULE__}), do: {:ok, conf}

  @doc """
  Sends the message via the specified worker process
  """
  @spec push(pid, Gcm.t) :: :ok | :error
  def push(pid, message), do: GenServer.call(pid, {:push, message})

  def handle_call({:push, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    headers = [
      "Content-Type": "application/json",
      "Authorization": "key=#{state[:key]}"
    ]
    res = HTTPotion.post(@gcm_server_url, [body: request, headers: headers])
    case Poison.decode!(res.body) do
      %{"results" => [%{"message_id" => id}]} ->
        {:reply, {:ok, id}, state}
      %{"results" => [%{"error" => error}]} ->
        {:reply, {:error, error}, state}
    end
  end
end
