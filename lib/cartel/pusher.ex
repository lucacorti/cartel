defmodule Cartel.Pusher do
  @moduledoc """
  `Cartel.Pusher` OTP Supervisor managing a pool of `Cartel.Pusher` workers
  """
  use Supervisor

  @doc """
  Sends the message via a free worker in the pool
  """
  def send(pool, type, message) do
    :poolboy.transaction(pool, fn worker -> type.send(worker, message) end)
  end

  @doc """
  Fetches feedback via a free worker in the pool
  """
  def feedback(pool, type) do
    :poolboy.transaction(pool, fn worker -> type.feedback(worker) end)
  end

  def start_link(pusher_id, pusher) do
    Supervisor.start_link(__MODULE__, [pusher_id, pusher], [])
  end

  def init([pusher_id, pusher]) do
    pool_options = Map.get(pusher, :pool, [size: 5, max_overflow: 10])
    pool_options = Keyword.put(pool_options, :name, {:local, pusher_id})
    pool_options = Keyword.put(pool_options, :worker_module, pusher[:type])

    [:poolboy.child_spec(pusher_id, pool_options, pusher)]
    |> supervise(strategy: :one_for_one)
  end
end
