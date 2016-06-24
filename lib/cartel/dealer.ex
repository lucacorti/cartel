defmodule Cartel.Dealer do
  @moduledoc """
  OTP Supervisor for each application
  """
  use Supervisor

  @doc """
  Starts the dealer
  """
  @spec start_link([id: String.t, pushers: %{}]) :: Supervisor.on_start
  def start_link(args = [id: appid, pushers: _]) do
    Supervisor.start_link(__MODULE__, args, name: name(appid), id: appid)
  end

  @doc """
  Generate the process name for the requested app
  """
  @spec name(String.t) :: atom
  def name(appid), do: String.to_atom("#{__MODULE__}@#{appid}")

  def init(args) do
    args[:pushers]
    |> Enum.map(fn {type, options} ->
      pusher_name = type.name(args[:id])

      pool_options = options
      |> Map.get(:pool, [])
      |> Keyword.put(:name, {:local, pusher_name})
      |> Keyword.put(:worker_module, type)

      :poolboy.child_spec(pusher_name, pool_options, options)
    end)
    |> supervise(strategy: :one_for_one)
  end
end
