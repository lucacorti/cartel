defmodule Cartel.Pusher do
  use Supervisor

  def start_link(pusher_id, pusher) do
    Supervisor.start_link(__MODULE__, [pusher_id, pusher], [])
  end

  def init([pusher_id, pusher]) do
    pool_options = [
      name: {:local, pusher_id},
      worker_module: pusher[:type],
      size: 5,
      max_overflow: 10
    ]
    [:poolboy.child_spec(pusher_id, pool_options, pusher)]
    |> supervise(strategy: :one_for_one)
  end

  def send(pool, type, message) do
    :poolboy.transaction(pool, fn worker -> type.send(worker, message) end)
  end

  def feedback(pool, type) do
    :poolboy.transaction(pool, fn worker -> type.feedback(worker) end)
  end
end
