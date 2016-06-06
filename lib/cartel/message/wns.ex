defmodule Cartel.Message.Wns do
  @moduledoc """
  Microsoft WNS message

  - `channel`: `String.t`, recipient channel URI obtained from the user
  - `type`: `String.t`, one of `type_toast/0`, `type_badge/0`, `type_tile/0` or `type_raw/0`
  - `cache_policy`: `boolean`, cache notification when device is offline.
  - `tag`: `String.t`, notification tag
  - `group`: `String.t`, notification group
  - `ttl`: `Integer.t`, duration in seconds since sending after which the notification expires
  - `suppress_popup`: `boolean`, suppress popups for `type_toast/0` notification
  - `request_for_status`: `boolean`, add device and connection status in reply
  - `payload`: `binary` containing raw octet stream data when `type` is `type_raw/0`, `String.t` serialized XML otherwise

  For more details on the format see [Push notification service request and response headers (Windows Runtime apps)](https://msdn.microsoft.com/en-us/library/windows/apps/hh465435.aspx)
  section of the [Sending push notifications with WNS](https://msdn.microsoft.com/en-us/library/windows/apps/hh465460.aspx)
  """

  @type t :: %__MODULE__{}

  @type_toast "wns/toast"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type toast
  """
  @spec type_toast :: String.t
  def type_toast, do: @type_toast

  @type_badge "wns/badge"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type badge
  """
  @spec type_badge :: String.t
  def type_badge, do: @type_badge

  @type_tile "wns/tile"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type tile
  """
  @spec type_tile :: String.t
  def type_tile, do: @type_tile

  @type_raw "wns/raw"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type raw
  """
  @spec type_raw :: String.t
  def type_raw, do: @type_raw

  defstruct [channel: nil, type: @type_toast, cache_policy: nil, tag: nil, ttl: 0,
             suppress_popup: nil, request_for_status: nil, group: nil,
             payload: ""]

  @doc """
  Returns the `Content-Type` HTTP header value for the message
  """
  @spec content_type(message :: %__MODULE__{}) :: String.t
  def content_type(%__MODULE__{type: @type_raw}) do
    "application/octet-stream"
  end

  def content_type(%__MODULE__{}) do
    "text/xml"
  end
end

defimpl Cartel.Message, for: Cartel.Message.Wns do
  def serialize(message) do
    message.payload
  end

  def update_token(message, token) do
    %{message | channel: token}
  end
end
