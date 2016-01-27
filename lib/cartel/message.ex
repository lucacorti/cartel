defmodule Cartel.Message do
  @callback encode(message :: Cartel.Pusher.Message.t) :: binary
  @callback decode(binary :: binary) :: Cartel.Pusher.Message.t
end
