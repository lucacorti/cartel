defmodule Cartel do
  @moduledoc """
  `Cartel` OTP Application
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    dealers = Application.get_env(:cartel, :dealers, [])
    Cartel.Supervisor.start_link(dealers)
  end
end
