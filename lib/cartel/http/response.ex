defmodule Cartel.HTTP.Response do
  @moduledoc false

  alias Cartel.HTTP

  @typedoc "HTTP response"
  @type t :: %__MODULE__{
          status: HTTP.status(),
          headers: HTTP.headers(),
          body: HTTP.body()
        }
  defstruct status: nil, headers: [], body: []

  @spec status(t()) :: HTTP.status()
  def status(%__MODULE__{status: status}), do: status

  @spec headers(t()) :: HTTP.headers()
  def headers(%__MODULE__{headers: headers}), do: headers

  @spec body(t()) :: HTTP.body()
  def body(%__MODULE__{body: body}), do: body
end
