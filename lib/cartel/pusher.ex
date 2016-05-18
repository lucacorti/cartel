defmodule Cartel.Pusher do
  @moduledoc """
  `Cartel.Pusher` Behaviour for push workers
  """

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
        Generate the registered process name for the requested app pusher
      """
      @spec name(String.t) :: atom
      def name(appid), do: :"#{__MODULE__}@#{appid}"

      @doc """
      Sends a push notification

      - `appid`: target application identifier present in `config.exs`
      - `message`: message struct
      - `tokens`: list of device tokens
      """
      @spec send(String.t, unquote(message_module).t, [String.t])
      :: {:ok | :error}
      def send(appid, message, tokens \\ [])

      def send(appid, message, []) do
        :poolboy.transaction(name(appid), fn
          worker ->
            __MODULE__.push(worker, message)
        end)
      end

      def send(appid, message = %unquote(message_module){}, tokens)
      when is_list(tokens) do
        :poolboy.transaction(name(appid), fn
          worker ->
            tokens
            |> Enum.map(fn
              token ->
                __MODULE__.push(worker, Message.update_token(message, token))
            end)
        end)
      end
    end
  end
end
