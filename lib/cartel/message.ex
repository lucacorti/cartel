defmodule Cartel.Message do
  use Behaviour

  defcallback encode(message :: Cartel.Pusher.Message.t) :: binary
  defcallback decode(binary :: binary) :: Cartel.Pusher.Message.t
end
