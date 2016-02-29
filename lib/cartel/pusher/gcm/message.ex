defmodule Cartel.Pusher.Gcm.Message do
  @derive Poison.Encoder
  defstruct [:to, :data]

  def decode(binary) do
    Poison.decode(binary)
  end

  def encode(message) do
    Encoder.encode(message)
  end
end
