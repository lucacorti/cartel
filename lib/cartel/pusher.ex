defmodule Cartel.Pusher do
  @moduledoc """
  `Cartel.Pusher` OTP Supervisor managing a pool of `Cartel.Pusher` workers
  """
  use Supervisor

  alias Cartel.Message

  @doc """
    Generate the registered process name for the requested app pusher
  """
  @spec name(String.t, atom, :sandbox | :production) :: atom
  def name(appid, type, env), do: :"#{type}@#{appid}/#{env}"

  @doc """
  Sends a push notification

  - `appid`: target application identifier present in `config.exs`
  - `type`: `Cartel.Pusher` submodule identifying target platform
  - `env`: target environment `:production` or `:sandbox`
  - `message`: `Cartel.Message` struct for the target platform
  """
  @spec send(String.t, atom, :sandbox | :production, Message.t)
  :: {:ok | :error}
  def send(appid, type, env, message) do
    :poolboy.transaction(name(appid, type, env), fn
      worker -> type.send(worker, message)
    end)
  end

  @doc """
  Sends a push notification

  - `appid`: target application identifier present in `config.exs`
  - `type`: `Cartel.Pusher` submodule identifying target platform
  - `env`: target environment `:production` or `:sandbox`
  - `tokens`: device tokens
  - `payload`: payload
  """
  @spec send_bulk(String.t, atom, :sandbox | :production, [String.t], [%{}])
  :: [{:ok | :error}]
  def send_bulk(appid, type, env, tokens, message) do
      tokens
      |> Enum.map(fn
        token -> send(appid, type, env, Message.update_token(message, token))
      end)
  end

  @doc """
  `Cartel.Dealer` method to fetch feedback, only works with `Cartel.Pusher.Apns`

  Returns an Enumerable `Stream` of `Cartel.Message.Apns.Feedback` structs.
  """
  @spec feedback(String.t, atom, :sandbox | :production) :: Stream.t
  def feedback(appid, type, env) do
    :poolboy.transaction(name(appid, type, env), fn
      worker -> type.feedback(worker)
    end)
  end

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, [])
  end

  def init([id: id, pusher: pusher]) do
    pool_options = Map.get(pusher, :pool, [size: 5, max_overflow: 10])

    pool_options = pool_options
    |> Keyword.put(:name, {:local, name(id, pusher[:type], pusher[:env])})
    |> Keyword.put(:worker_module, pusher[:type])

    [:poolboy.child_spec(
      name(id, pusher[:type], pusher[:env]), pool_options, pusher
    )]
    |> supervise(strategy: :one_for_one)
  end
end
