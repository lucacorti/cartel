defmodule Cartel.Message do
  @moduledoc """
  Behaviour callbacks to be implemented by message implementations
  """
  @callback serialize(message :: Cartel.Message) :: binary
  @callback deserialize(binary :: binary) :: Cartel.Message
end
