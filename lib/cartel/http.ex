defmodule Cartel.HTTP do
  @moduledoc """
  HTTP Client
  """

  alias Cartel.HTTP.{Request, Response}

  @type t :: %__MODULE__{conn: Mint.HTTP.t() | nil}
  @type scheme :: :http | :https
  @type status :: integer()
  @type host :: String.t()
  @type method :: String.t()
  @type url :: String.t()
  @type body :: iodata() | nil
  @type header :: {String.t(), String.t()}
  @type headers :: [header()]

  @typedoc """
  HTTP request options

  Available options are
    - `follow_redirects`: If true, when an HTTP redirect is received a new request is made to the redirect URL, else the redirect is returned. Defaults to `true`
    - `max_redirects`: Maximum number of redirects to follow, defaults to `10`
    - `request_timeout`: Timeout for the request, defaults to `20 seconds`
    - `query_params`: Enumerable containing key-value query parameters to add to the url

  Defaults can be changed by setting values in the app configuration:
  ```elixir
  config :cartel, :http,
    max_redirects: 4,
    request_timeout: 5_000
  ```
  """
  @type options :: [
          request_timeout: integer(),
          max_redirects: integer(),
          follow_redirects: boolean(),
          query_params: Enum.t()
        ]

  defstruct conn: nil

  @doc """
  Establish an HTTP connection

  Returns the connection stucture to use for subsequent requests.
  """
  @spec connect(url, options) :: {:ok, t()} | {:error, term}
  def connect(url, options \\ []) do
    with %URI{scheme: scheme, host: host, port: port} <- URI.parse(url),
         {:ok, conn} <-
           scheme
           |> String.downcase()
           |> String.to_existing_atom()
           |> Mint.HTTP.connect(host, port, options),
         do: {:ok, %__MODULE__{conn: conn}}
  end

  @doc """
  Close an HTTP connection
  """
  @spec close(t()) :: :ok | {:error, term}
  def close(%{conn: conn}) do
    with {:ok, _conn} <- Mint.HTTP.close(conn), do: :ok
  end

  @doc """
  Performs an HTTP request

  Returns the connection stucture to use for subsequent requests.
  """
  @spec request(t(), Request.t()) :: {:ok, t(), Response.t()} | {:error, term}
  def request(connection, %Request{
        method: method,
        url: url,
        headers: headers,
        body: body,
        options: options
      }) do
    request(connection, method, url, body, headers, options)
  end

  @doc """
  Performs an HTTP request

  Returns the connection stucture to use for subsequent requests.
  """
  @spec request(t, method, url, body, headers, options) ::
          {:ok, t(), Response.t()} | {:error, term}
  def request(connection, method, url, body \\ nil, headers \\ [], options \\ [])

  def request(%__MODULE__{conn: nil}, method, url, body, headers, options) do
    with {:ok, connection} <- connect(url, options),
         do: request(connection, method, url, body, headers, options)
  end

  def request(%__MODULE__{conn: conn} = connection, method, url, body, headers, options) do
    follow_redirects = get_option(options, :follow_redirects, true)

    with %URI{path: path, query: query} <- URI.parse(url),
         {:ok, conn, request_ref} <-
           Mint.HTTP.request(
             conn,
             method,
             process_request_url(path, query, options),
             headers,
             body
           ),
         {:ok, conn, response} when conn != :error and not follow_redirects <-
           receive_msg(conn, %Response{}, request_ref, options) do
      {:ok, %{connection | conn: conn}, response}
    else
      {:ok, conn, %Response{status: status, headers: response_headers} = response} ->
        case Enum.find(response_headers, fn {header, _value} -> header == "location" end) do
          {_header, redirect_url} when follow_redirects and (status >= 300 and status < 400) ->
            max_redirects = get_option(options, :max_redirects, 10)

            redirect(
              %{connection | conn: conn},
              method,
              URI.parse(url),
              URI.parse(redirect_url),
              body,
              headers,
              options,
              max_redirects
            )

          _ ->
            {:ok, %{connection | conn: conn}, response}
        end

      {:error, %Mint.TransportError{reason: reason}} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}

      error ->
        error
    end
  end

  defp redirect(
         _connection,
         _method,
         _original_url,
         _redirect_url,
         _body,
         _headers,
         _options,
         max_redirects
       )
       when max_redirects == 0 do
    {:error, :too_many_redirects}
  end

  defp redirect(
         connection,
         method,
         %URI{scheme: original_scheme} = original_url,
         %URI{scheme: redirect_scheme} = redirect_url,
         body,
         headers,
         options,
         max_redirects
       )
       when is_nil(redirect_scheme) do
    redirect(
      connection,
      method,
      original_url,
      %{redirect_url | scheme: original_scheme},
      body,
      headers,
      options,
      max_redirects - 1
    )
  end

  defp redirect(
         _connection,
         method,
         %URI{scheme: original_scheme, host: original_host, port: original_port},
         %URI{scheme: redirect_scheme, host: redirect_host, port: redirect_port} = redirect_url,
         body,
         headers,
         options,
         max_redirects
       )
       when redirect_scheme != original_scheme or
              redirect_host != original_host or
              redirect_port != original_port do
    options = put_option(options, :max_redirects, max_redirects - 1)
    request(%__MODULE__{}, method, URI.to_string(redirect_url), body, headers, options)
  end

  defp redirect(
         connection,
         method,
         _original_url,
         redirect_url,
         body,
         headers,
         options,
         max_redirects
       ) do
    options = put_option(options, :max_redirects, max_redirects - 1)
    request(connection, method, URI.to_string(redirect_url), body, headers, options)
  end

  defp receive_msg(conn, response, request_ref, options) do
    socket = Mint.HTTP.get_socket(conn)
    timeout = get_option(options, :request_timeout, 20_000)

    receive do
      {tag, ^socket, _data} = msg when tag in [:tcp, :ssl] ->
        handle_msg(conn, request_ref, msg, response, options)

      {tag, ^socket} = msg when tag in [:tcp_closed, :ssl_closed] ->
        handle_msg(conn, request_ref, msg, response, options)

      {tag, ^socket, _reason} = msg when tag in [:tcp_error, :ssl_error] ->
        handle_msg(conn, request_ref, msg, response, options)
    after
      timeout ->
        {:error, :timeout}
    end
  end

  defp handle_msg(conn, request_ref, msg, response, options) do
    with {:ok, conn, responses} <- Mint.HTTP.stream(conn, msg),
         {:ok, conn, {response, true}} <-
           handle_responses(conn, response, responses, request_ref) do
      {:ok, conn, response}
    else
      :unknown ->
        receive_msg(conn, response, request_ref, options)

      {:error, _, %{reason: reason}, _} ->
        {:error, reason}

      {:ok, conn, {response, false}} ->
        receive_msg(conn, response, request_ref, options)
    end
  end

  defp handle_responses(conn, response, responses, request_ref) do
    {response, complete} =
      responses
      |> Enum.reduce({response, false}, fn
        {:status, ^request_ref, v}, {response, complete} ->
          {%Response{response | status: v}, complete}

        {:data, ^request_ref, v}, {%Response{body: body} = response, complete} ->
          {%Response{response | body: [v | body]}, complete}

        {:headers, ^request_ref, v}, {response, complete} ->
          {%Response{response | headers: v}, complete}

        {:done, ^request_ref}, {%Response{body: body} = response, _complete} ->
          {%Response{response | body: Enum.reverse(body)}, true}
      end)

    {:ok, conn, {response, complete}}
  end

  defp get_option(options, option, default) do
    default_value =
      :cartel
      |> Application.get_env(:http, [])
      |> Keyword.get(option, default)

    Keyword.get(options, option, default_value)
  end

  defp put_option(options, option, value) do
    Keyword.put(options, option, value)
  end

  defp process_request_url(nil = _path, query, options),
    do: process_request_url("/", query, options)

  defp process_request_url(path, nil = _query, options),
    do: process_request_url(path, "", options)

  defp process_request_url(path, query, options) do
    query_params =
      options
      |> Keyword.get(:query_params, [])
      |> encode_query()

    path <> "?" <> query <> "&" <> query_params
  end

  defp encode_query([]), do: ""
  defp encode_query(%{}), do: ""

  defp encode_query(query_params) do
    query_params
    |> URI.encode_query()
  end
end
