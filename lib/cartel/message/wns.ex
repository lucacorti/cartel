defmodule Cartel.Message.Wns do
  @moduledoc """
  WNS message format
  """

  alias Cartel.Message.Encoder

  @behaviour Cartel.Message

  def deserialize(binary) do
    binary
  end

  def serialize(message) do
    Encoder.encode(message)
  end
end
