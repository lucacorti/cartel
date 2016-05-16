defmodule Cartel.Pusher do
  @moduledoc """
  `Cartel.Pusher` Behaviour and OTP Supervisor managing `Cartel.Pusher` workers
  """
  use Supervisor

  alias Cartel.Message

  @doc """
  Callback for Pusher behaviour implementors
  """
  @callback push(pid :: pid, message :: Message.t) :: :ok | :error

  defmacro __using__([message_module: message_module]) do
    quote do
      @behaviour Cartel.Pusher

      alias Cartel.Pusher
      alias Cartel.Message

      @doc """
      Sends a push notification

      - `appid`: target application identifier present in `config.exs`
      - `message`: message struct
      """
      @spec send(String.t, unquote(message_module).t) :: {:ok | :error}
      def send(appid, message, tokens \\ [])

      def send(appid, message, []) do
        :poolboy.transaction(Pusher.name(appid, __MODULE__), fn
          worker ->
            __MODULE__.push(worker, message)
        end)
      end

      def send(appid, message = %unquote(message_module){}, tokens)
      when is_list(tokens) do
        tokens
        |> Enum.map(fn
          token ->
            __MODULE__.send(appid, Message.update_token(message, token))
        end)
      end

      @doc """
      Bulk sends the same push notification to multiple recipients

      - `appid`: target application identifier present in `config.exs`
      - `tokens`: device tokens
      - `message`: message struct
      """
      @spec send_bulk(String.t, [String.t], unquote(message_module).t)
      :: [{:ok | :error}]
      def send_bulk(appid, tokens, message = %unquote(message_module){}) do
          tokens
          |> Enum.map(fn
            token ->
              __MODULE__.send(appid, Message.update_token(message, token))
          end)
      end
    end
  end

  @doc """
    Generate the registered process name for the requested app pusher
  """
  @spec name(String.t, atom) :: atom
  def name(appid, type), do: :"#{type}@#{appid}"

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, [])
  end

  def init([id: id, pusher: pusher]) do
    pusher_name = name(id, pusher[:type])
    pool_options = Map.get(pusher, :pool, [size: 5, max_overflow: 10])

    pool_options = pool_options
    |> Keyword.put(:name, {:local, pusher_name})
    |> Keyword.put(:worker_module, pusher[:type])

    [:poolboy.child_spec(pusher_name, pool_options, pusher)]
    |> supervise(strategy: :one_for_one)
  end
end
