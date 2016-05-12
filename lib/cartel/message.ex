defprotocol Cartel.Message do
  @moduledoc """
  Protocol to be implemented by `Cartel.Message` structs
  """

  @typedoc """
  Struct conforming to the `Cartel.Message` protocol
  """
  @type t :: struct

  @doc """
  Serializes `Cartel.Message` struct to binary
  """
  @spec serialize(t) :: binary
  def serialize(message)

  @doc """
  Returns an updated message with the new `token`
  """
  @spec update_token(t, String.t) :: t
  def update_token(message, token)
end
