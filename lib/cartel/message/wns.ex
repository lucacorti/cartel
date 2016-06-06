defmodule Cartel.Message.Wns do
  @moduledoc """
  Microsoft WNS message
  """

  @type t :: %__MODULE__{}

  @type_toast "wns/toast"
  def type_toast, do: @type_toast

  @type_badge "wns/badge"
  def type_badge, do: @type_badge

  @type_tile "wns/tile"
  def type_tile, do: @type_tile

  @type_raw "wns/raw"
  def type_raw, do: @type_raw

  defstruct [channel: nil, type: @type_raw, cache_policy: false, tag: nil, ttl: 0,
             suppress_popup: false, request_for_status: false, group: nil,
             payload: ""]

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
