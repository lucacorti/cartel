defmodule Cartel.HTTP.Request do
  @moduledoc false

  alias Cartel.HTTP

  @typedoc "HTTP request"
  @type t :: %__MODULE__{
          method: HTTP.method(),
          url: HTTP.url(),
          headers: HTTP.headers(),
          body: HTTP.body(),
          options: HTTP.options()
        }
  defstruct method: nil, url: nil, headers: [], body: [], options: []

  @spec new(HTTP.url(), HTTP.method(), HTTP.headers(), HTTP.body(), HTTP.options()) :: t()
  def new(url, method \\ "GET", headers \\ [], body \\ [], options \\ []),
    do: %__MODULE__{url: url, method: method, headers: headers, body: body, options: options}

  @spec set_method(t(), HTTP.method()) :: t()
  def set_method(request, method), do: %__MODULE__{request | method: method}

  @spec set_body(t(), HTTP.body()) :: t()
  def set_body(request, body), do: %__MODULE__{request | body: body}

  @spec set_headers(t(), HTTP.headers()) :: t()
  def set_headers(request, headers), do: %__MODULE__{request | headers: headers}

  @spec set_options(t(), HTTP.options()) :: t()
  def set_options(request, options), do: %__MODULE__{request | options: options}

  @spec put_header(t(), HTTP.header()) :: t()
  def put_header(%__MODULE__{headers: headers} = request, header),
    do: %__MODULE__{request | headers: [header | headers]}

  @spec put_option(t(), HTTP.option()) :: t()
  def put_option(%__MODULE__{options: options} = request, option),
    do: %__MODULE__{request | options: [option | options]}
end
