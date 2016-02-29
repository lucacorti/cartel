defmodule Cartel.Message do
  @callback serialize(message :: Cartel.Message) :: binary
  @callback deserialize(binary :: binary) :: Cartel.Message
end
