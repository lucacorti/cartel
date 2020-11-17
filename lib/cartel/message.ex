defprotocol Cartel.Message do
  @moduledoc """
  Protocol for the implementation of message formats
  """

  @typedoc """
  Struct conforming to the `Cartel.Message` protocol
  """
  @type t :: struct

  @doc """
  Serializes the message struct for sending
  """
  @spec serialize(t) :: binary
  def serialize(message)

  @doc """
  Returns a copy of message with the `token` updated
  """
  @spec update_token(t, String.t()) :: t
  def update_token(message, token)
end
