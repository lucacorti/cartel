defmodule Cartel.Pusher.Gcm.Message do
  @behaviour Cartel.Message
  @derive Poison.Encoder
  defstruct [:to, :data]

  def encode(message) do
    Poison.encode(message)
  end

  def decode(binary) do
    Poison.decode(binary)
  end
end
