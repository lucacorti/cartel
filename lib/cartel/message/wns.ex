defmodule Cartel.Message.Wns do
  alias Cartel.Message.Encoder

  @behaviour Cartel.Message

  def deserialize(binary) do
    binary
  end

  def serialize(message) do
    Encoder.encode(message)
  end
end
