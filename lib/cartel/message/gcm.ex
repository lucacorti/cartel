defmodule Cartel.Message.Gcm do
  @moduledoc """
  Google GCM message format
  """

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

defimpl Cartel.Message.Encoder, for: Cartel.Message.Gcm do
  def encode(message) do
    Poison.encode(message)
  end
end
