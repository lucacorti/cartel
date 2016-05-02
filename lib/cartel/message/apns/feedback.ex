defmodule Cartel.Message.Apns.Feedback do
  alias Cartel.Message.Encoder
  defstruct [time: nil, token: nil]

  @behaviour Cartel.Message

  @record_size 38
  def record_size, do: @record_size

  def deserialize(<<time::size(32), 32::size(16), token::size(256)>>) do
    %Cartel.Message.Apns.Feedback{time: time, token: token}
  end

  def serialize(message) do
    Encoder.encode(message)
  end
end

defimpl Cartel.Message.Encoder, for: Cartel.Message.Apns.Feedback do
  alias Cartel.Message.Apns.Feedback
  def encode(%Feedback{time: time, token: token}) do
    {:ok, encoded} = Base.decode16(token, case: :mixed)
    <<time::size(32), 32::size(16), encoded::size(256)>>
  end
end
