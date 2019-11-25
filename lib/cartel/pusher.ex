defmodule Cartel.Pusher do
  @moduledoc """
  Behaviour for the implementation of push workers
  """

  alias Cartel.Message

  @doc """
  Pushers must implement actual message sending via this callback

  - `message`: The message struct of the message to be sent, included to allow
  metadata additions by the `Cartel.Pusher.handle_push/3` impelementation.
  - `payload`: binary to be used for wire transmission, encoded via the message
  `Cartel.Message.serialize/1` implementation.
  """
  @callback handle_push(pid :: pid, message :: Message.t(), payload :: binary) ::
              :ok | :error

  defmacro __using__(message_module: message_module) do
    quote do
      @behaviour Cartel.Pusher

      alias Cartel.{Message, Pusher}

      @doc """
      Generate the process name for the requested app
      """
      @spec name(String.t()) :: atom
      def name(appid), do: String.to_atom("#{__MODULE__}@#{appid}")

      @doc """
      Sends a push notification

      - `appid`: target application identifier present in `config.exs`
      - `message`: message struct
      - `tokens`: list of recipient device tokens
      """
      @spec send(String.t(), unquote(message_module).t, [String.t()]) ::
              {:ok | :error}
      def send(appid, message, tokens \\ [])

      def send(appid, %unquote(message_module){} = message, []) do
        :poolboy.transaction(name(appid), fn
          worker ->
            payload = Message.serialize(message)
            __MODULE__.handle_push(worker, message, payload)
        end)
      end

      def send(appid, %unquote(message_module){} = message, tokens)
          when is_list(tokens) do
        :poolboy.transaction(name(appid), fn
          worker ->
            tokens
            |> Enum.map(fn
              token ->
                message = Message.update_token(message, token)
                payload = Message.serialize(message)
                __MODULE__.handle_push(worker, message, payload)
            end)
        end)
      end
    end
  end
end
