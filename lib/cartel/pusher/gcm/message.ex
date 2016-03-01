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
