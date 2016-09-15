defmodule Cartel do
  @moduledoc """
  Cartel OTP Application
  """
  use Application

  alias Cartel.{Dealer, Supervisor}

  def start(_type, _args) do
    supervisor = Supervisor.start_link()

    dealers = Application.get_env(:cartel, :dealers, [])
    for {appid, pushers} <- dealers, do: {:ok, _} = Dealer.add(appid, pushers)

    supervisor
  end
end
