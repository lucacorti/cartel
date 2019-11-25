defmodule Cartel.Dealer do
  @moduledoc """
  OTP Supervisor for each application
  """
  use Supervisor

  @doc """
  Starts the dealer
  """
  @spec start_link(id: String.t(), pushers: %{}) :: Supervisor.on_start()
  def start_link([id: app_id, pushers: _] = args) do
    Supervisor.start_link(__MODULE__, args, id: app_id)
  end

  @spec name(String.t()) :: atom()
  defp name(app_id), do: String.to_atom("#{__MODULE__}@#{app_id}")

  def init(%{id: id, pushers: pushers}) do
    pushers
    |> Enum.map(fn {type, options} ->
      pusher_name = type.name(id)

      pool_options =
        options
        |> Map.get(:pool, [])
        |> Keyword.put(:name, {:local, pusher_name})
        |> Keyword.put(:worker_module, type)

      :poolboy.child_spec(pusher_name, pool_options, options)
    end)
    |> supervise(strategy: :one_for_one)
  end

  @doc """
  Adds a new Dealer to the supervision tree.

  - app_id: The app name
  - pushers: pushers as you specify in the static configuration
  """
  @spec add(String.t(), %{}) :: Supervisor.on_start_child()
  def add(app_id, pushers) do
    Supervisor.start_child(Cartel.Supervisor, [[id: app_id, pushers: pushers]])
  end

  @doc """
  Removes a Dealer from the supervision tree.

  - app_id: The app name
  """
  @spec remove(String.t()) :: :ok | {:error, :not_found}
  def remove(app_id) do
    case whereis(app_id) do
      {:ok, pid} ->
        Supervisor.terminate_child(Cartel.Supervisor, pid)

      error ->
        error
    end
  end

  defp whereis(app_id) do
    app_name = name(app_id)
    case Process.whereis(app_name) do
      pid when is_pid(pid) ->
        {:ok, pid}

      _ ->
        {:error, :not_found}
    end
  end
end
