defmodule Cartel do
  @moduledoc """
  Cartel OTP Application
  """
  use Application

  def start(_type, _args) do
    dealers = Application.get_env(:cartel, :dealers, [])
    supervisor = Cartel.Supervisor.start_link()

    dealers
    |> Enum.each(fn {appid, pushers} ->
      {:ok, _} = Cartel.Supervisor.add_dealer(appid, pushers)
    end)

    supervisor
  end
end
