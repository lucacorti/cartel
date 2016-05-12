defmodule Cartel.Pusher do
  @moduledoc """
  `Cartel.Pusher` Behaviour and OTP Supervisor managing `Cartel.Pusher` workers
  """
  use Supervisor

  alias Cartel.Message

  @doc """
  Callback for Pusher behaviour implementors
  """
  @callback send(pid :: pid, message :: Message.t) :: :ok | :error

  defmacro __using__(_) do
    quote do
      @behaviour Cartel.Pusher

      alias Cartel.Pusher
      alias Cartel.Message

      @doc """
      Sends a push notification

      - `appid`: target application identifier present in `config.exs`
      - `env`: target environment `:production` or `:sandbox`
      - `message`: `Cartel.Message` struct for the target platform
      """
      @spec send(String.t, :sandbox | :production, Message.t) :: {:ok | :error}
      def send(appid, env, message) do
        :poolboy.transaction(Pusher.name(appid, __MODULE__, env), fn
          worker ->
            __MODULE__.send(worker, message)
        end)
      end

      @doc """
      Bulk sends the same push notification to multiple recipients

      - `appid`: target application identifier present in `config.exs`
      - `env`: target environment `:production` or `:sandbox`
      - `tokens`: device tokens
      - `payload`: payload
      """
      @spec send_bulk(String.t, :sandbox | :production, [String.t], [%{}])
      :: [{:ok | :error}]
      def send_bulk(appid, env, tokens, message) do
          tokens
          |> Enum.map(fn
            token ->
              __MODULE__.send(appid, env, Message.update_token(message, token))
          end)
      end
    end
  end

  @doc """
    Generate the registered process name for the requested app pusher
  """
  @spec name(String.t, atom, :sandbox | :production) :: atom
  def name(appid, type, env), do: :"#{type}@#{appid}/#{env}"

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
