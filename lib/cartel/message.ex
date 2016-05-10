defmodule Cartel.Message do
  @moduledoc """
  Behaviour callbacks to be implemented by message implementations
  """

  @doc """
  Serializes `Cartel.Message` struct to binary
  """
  @callback serialize(message :: Cartel.Message) :: binary

  @doc """
  Deserializes binary to `Cartel.Message` struct
  """
  @callback deserialize(binary :: binary) :: Cartel.Message
end
