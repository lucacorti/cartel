defmodule Cartel.Pusher do
  @callback send(pname :: Atom, message :: Cartel.Message) :: :ok
end
