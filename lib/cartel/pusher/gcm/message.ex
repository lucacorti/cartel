defmodule Cartel.Pusher.Gcm.Message do
  alias Cartel.Message.Encoder

  @derive Poison.Encoder
  defstruct [:to, :data]

  def decode(binary) do
    Poison.decode(binary)
  end

  def encode(message) do
    Encoder.encode(message)
  end
end
