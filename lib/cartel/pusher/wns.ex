defmodule Cartel.Pusher.Wns do
  @moduledoc """
  Microsoft WNS interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Wns

  alias Cartel.HTTP
  alias Cartel.Message.Wns
  alias HTTP.{Request, Response}

  @wns_login_url "https://login.live.com/accesstoken.srf"

  @doc """
  Starts the pusher
  """
  @spec start_link(%{sid: String.t(), secret: String.t()}) :: GenServer.on_start()
  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def init(conf), do: {:ok, %{conf: conf, token: nil}}

  def handle_push(pid, message, payload) do
    GenServer.call(pid, {:push, message, payload})
  end

  def handle_call(
        {:push, message, payload},
        from,
        %{token: nil, conf: %{sid: sid, secret: secret}} = state
      ) do
    case login(sid, secret) do
      {:ok, token} ->
        handle_call({:push, message, payload}, from, %{state | token: token})

      {:error, reason} ->
        {:stop, {:error, reason}, state}
    end
  end

  def handle_call({:push, %Wns{channel: channel} = message, payload}, _from, state) do
    headers = message_headers(message)

    request =
      channel
      |> Request.new("POST")
      |> Request.set_body(payload)
      |> Request.set_headers(headers)
      |> Request.put_header({"content-type", Wns.content_type(message)})
      |> Request.put_header({"authorization", "Bearer " <> state[:key]})
      |> Request.put_header({"x-wns-type", message.type})

    case HTTP.request(%HTTP{}, request) do
      {:ok, _, %Response{status: code, headers: headers}} when code >= 400 ->
        {:reply, {:error, headers}, state}

      {:ok, _, %Response{}} ->
        {:reply, :ok, state}

      {:error, reason} ->
        {:stop, {:error, reason}, state}
    end
  end

  defp login(client_id, client_secret) do
    body =
      %{
        grant_type: "client_credentials",
        scope: "notify.windows.com",
        client_id: client_id,
        client_secret: client_secret
      }
      |> URI.encode_query()

    request =
      @wns_login_url
      |> Request.new("POST")
      |> Request.set_body(body)
      |> Request.put_header({"content-type", "application/x-www-form-urlencoded"})

    case HTTP.request(%HTTP{}, request) do
      {:ok, _, %Response{body: body}} ->
        {:ok, Jason.decode!(body)["access_token"]}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp message_headers(message) do
    []
    |> add_message_header_cache_policy(message)
    |> add_message_header_ttl(message)
    |> add_message_header_suppress_popup(message)
    |> add_message_header_request_for_status(message)
  end

  defp add_message_header_cache_policy(headers, %Wns{cache_policy: true}) do
    [{"X-WNS-Cache-Policy", "cache"} | headers]
  end

  defp add_message_header_cache_policy(headers, %Wns{cache_policy: false}) do
    [{"X-WNS-Cache-Policy", "no-cache"} | headers]
  end

  defp add_message_header_cache_policy(headers, _), do: headers

  defp add_message_header_ttl(headers, %Wns{ttl: ttl}) when is_integer(ttl) and ttl > 0 do
    [{"X-WNS-TTL", ttl} | headers]
  end

  defp add_message_header_ttl(headers, _), do: headers

  defp add_message_header_suppress_popup(headers, %Wns{suppress_popup: suppress_popup})
       when is_boolean(suppress_popup) and suppress_popup == true do
    [{"X-WNS-SuppressPopup", "true"} | headers]
  end

  defp add_message_header_suppress_popup(headers, _), do: headers

  defp add_message_header_request_for_status(headers, %Wns{request_for_status: request_for_status})
       when is_boolean(request_for_status) and request_for_status == true do
    [{"X-WNS-RequestForStatus", "true"} | headers]
  end

  defp add_message_header_request_for_status(headers, _), do: headers
end
