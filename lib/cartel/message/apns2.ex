defmodule Cartel.Message.Apns2 do
  @moduledoc """
  APNS HTTP/2 interface message format
  """

  @type t :: %__MODULE__{}

  defstruct [
    token: nil, id: nil, expiration: 0, priority: 10, topic: nil, payload: %{}
  ]
end

defimpl Cartel.Message, for: Cartel.Message.Apns2 do
  def serialize(message) do
    Poison.encode!(message.payload)
  end

  def update_token(message, token) do
    %{message | token: token}
  end
end
