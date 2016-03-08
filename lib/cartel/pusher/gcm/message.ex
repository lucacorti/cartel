defmodule Cartel.Pusher.Gcm.Message do
  alias Cartel.Message.Encoder

  @behaviour Cartel.Message

  @derive Poison.Encoder
  defstruct [:to, :data]

  def deserialize(binary) do
    Poison.decode(binary)
  end

  def serialize(message) do
    Encoder.encode(message)
  end
end

defimpl Cartel.Message.Encoder, for: Cartel.Pusher.Gcm.Message do
  def encode(message) do
    Poison.encode(message)
  end
end
