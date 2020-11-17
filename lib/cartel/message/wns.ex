defmodule Cartel.Message.Wns do
  @moduledoc """
  Microsoft WNS message

  For more details on the format see [Push notification service request and response headers (Windows Runtime apps)](https://msdn.microsoft.com/en-us/library/windows/apps/hh465435.aspx)
  section of the [Sending push notifications with WNS](https://msdn.microsoft.com/en-us/library/windows/apps/hh465460.aspx)
  """

  @type_toast "wns/toast"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type toast
  """
  @spec type_toast :: String.t()
  def type_toast, do: @type_toast

  @type_badge "wns/badge"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type badge
  """
  @spec type_badge :: String.t()
  def type_badge, do: @type_badge

  @type_tile "wns/tile"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type tile
  """
  @spec type_tile :: String.t()
  def type_tile, do: @type_tile

  @type_raw "wns/raw"

  @doc """
  Returns the `X-WNS-Type` HTTP header value for type raw
  """
  @spec type_raw :: String.t()
  def type_raw, do: @type_raw

  @typedoc """
  Microsoft WNS message

  - `channel`: recipient channel URI obtained from the user
  - `type`: one of `type_toast/0`, `type_badge/0`, `type_tile/0` or `type_raw/0`
  - `tag`: notification tag
  - `group`: notification group
  - `ttl`: seconds since sending after which the notification expires
  - `cache_policy`: wether to cache notification when device is offline.
  - `suppress_popup`: suppress popups for `type_toast/0` notification
  - `request_for_status`: add device and connection status in reply
  - `payload`: raw octet stream data when `type` is `type_raw/0`, serialized XML string otherwise
  """
  @type t :: %__MODULE__{
          channel: String.t(),
          type: String.t(),
          tag: String.t(),
          group: String.t(),
          ttl: Integer.t(),
          cache_policy: boolean,
          suppress_popup: boolean,
          request_for_status: boolean,
          payload: binary | String.t()
        }
  defstruct channel: nil,
            type: @type_toast,
            cache_policy: nil,
            tag: nil,
            ttl: 0,
            suppress_popup: nil,
            request_for_status: nil,
            group: nil,
            payload: ""

  @doc """
  Returns the `Content-Type` HTTP header value for the message
  """
  @spec content_type(message :: %__MODULE__{}) :: String.t()
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
