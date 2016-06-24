defmodule Cartel.Supervisor do
  @moduledoc """
  Cartel supervisor for dealer processes
  """
  use Supervisor

  alias Cartel.Dealer

  @doc """
  Starts the supervisor
  """
  @spec start_link() :: Supervisor.on_start
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Dealer, [], restart: :permanent)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Adds a new Dealer to the supervision tree.

  - appid: The app name
  - pushers: pushers as you specify in the static configuration
  """
  @spec add_dealer(String.t, %{}) :: Supervisor.on_start_child
  def add_dealer(appid, pushers) do
    Supervisor.start_child(__MODULE__, [[id: appid, pushers: pushers]])
  end

  @doc """
  Removes a Dealer from the supervision tree.

  - appid: The app name
  """
  @spec remove_dealer(String.t) :: :ok | {:error, :not_found}
  def remove_dealer(appid) do
    case whereis_dealer(appid) do
      {:ok, pid} ->
        Supervisor.terminate_child(__MODULE__, pid)
      error ->
        error
    end
  end

  @spec whereis_dealer(String.t) :: {:ok, pid} | {:error, :not_found}
  defp whereis_dealer(appid) do
    case Process.whereis(Dealer.name(appid)) do
      nil ->
        {:error, :not_found}
      pid ->
        {:ok, pid}
    end
  end
end
