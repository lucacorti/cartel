defmodule Cartel.Pusher do
  @callback send(pid, message :: Cartel.Message) :: :ok
end
