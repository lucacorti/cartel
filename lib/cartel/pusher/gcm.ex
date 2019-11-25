defmodule Cartel.Pusher.Gcm do
  @moduledoc """
  Google GCM interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Gcm

  alias Cartel.HTTP
  alias HTTP.{Request, Response}

  @gcm_server_url "https://gcm-http.googleapis.com/gcm/send"

  @doc """
  Starts the pusher
  """
  @spec start_link(%{key: String.t()}) :: GenServer.on_start()
  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf), do: {:ok, conf}

  def handle_push(pid, message, payload) do
    GenServer.call(pid, {:push, message, payload})
  end

  def handle_call({:push, _message, payload}, _from, state) do
    request =
      @gcm_server_url
      |> Request.new("POST")
      |> Request.set_body(payload)
      |> Request.put_header({"content-type", "application/json"})
      |> Request.put_header({"authorization", "key=" <> state[:key]})

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
end
