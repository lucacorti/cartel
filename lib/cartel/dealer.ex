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
    Supervisor.start_link(__MODULE__, args, id: appid)
  end

  @spec name(String.t) :: atom
  defp name(appid), do: "#{__MODULE__}@#{appid}"

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

  @doc """
  Adds a new Dealer to the supervision tree.

  - appid: The app name
  - pushers: pushers as you specify in the static configuration
  """
  @spec add(String.t, %{}) :: Supervisor.on_start_child
  def add(appid, pushers) do
    Supervisor.start_child(Cartel.Supervisor, [[id: appid, pushers: pushers]])
  end

  @doc """
  Removes a Dealer from the supervision tree.

  - appid: The app name
  """
  @spec remove(String.t) :: :ok | {:error, :not_found}
  def remove(appid) do
    case whereis(appid) do
      {:ok, pid} ->
        Supervisor.terminate_child(Cartel.Supervisor, pid)
      error ->
        error
    end
  end

  @spec whereis(String.t) :: {:ok, pid} | {:error, :not_found}
  defp whereis(appid) do
    case Process.whereis(name(appid)) do
      pid when is_pid(pid) ->
        {:ok, pid}
      _ ->
        {:error, :not_found}
    end
  end
end
