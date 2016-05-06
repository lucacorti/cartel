defmodule Cartel.Message.Apns2 do
  @moduledoc """
  APNS HTTP/2 interface message format
  """

  alias Cartel.Message.Encoder

  defstruct [
    token: nil, id: nil, expiration: 0, priority: 10, topic: nil, payload: %{}
  ]

  @behaviour Cartel.Message

  def serialize(message) do
    Encoder.encode(message)
  end

  def deserialize(binary) do
    Poison.decode(binary)
  end
end

defimpl Cartel.Message.Encoder, for: Cartel.Message.Apns2 do
  def encode(message) do
    Poison.encode!(message.payload)
  end
end
