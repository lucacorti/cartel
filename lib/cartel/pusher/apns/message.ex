defmodule Cartel.Pusher.Apns.Message do
  alias Cartel.Message.Encoder

  defstruct [items: []]

  @behaviour Cartel.Message

  @no_errors 0
  @processing_error 1
  @missing_token 2
  @missing_topic 3
  @missing_payload 4
  @invalid_token_size 5
  @invalid_topic_size 6
  @invalid_payload_size 7
  @invalid_token 8
  @shutdown 10
  @unknown_error 255

  defp status_to_string(@no_errors), do: "No errors encountered"
  defp status_to_string(@processing_error), do: "Processing error"
  defp status_to_string(@missing_token), do: "Missing device token"
  defp status_to_string(@missing_topic), do: "Missing topic"
  defp status_to_string(@missing_payload), do: "Missing payload"
  defp status_to_string(@invalid_token_size), do: "Invalid token size"
  defp status_to_string(@invalid_topic_size), do: "Invalid topic size"
  defp status_to_string(@invalid_payload_size), do: "Invalid payload_size"
  defp status_to_string(@invalid_token), do: "Invalid token"
  defp status_to_string(@shutdown), do: "Shutdown"
  defp status_to_string(status), do: "None (unknown)"

  def deserialize(binary) do
    case binary do
      <<8::size(8), status::size(8), identifier::size(32)>> ->
        {:error, identifier, status, status_to_string(status)}
    end
  end

  def serialize(message) do
    Encoder.encode(message)
  end
end

defimpl Cartel.Message.Encoder, for: Cartel.Pusher.Apns.Message do
  alias Cartel.Pusher.Apns.Message.Item

  def encode(message) do
    items = Enum.map_join(message.items, fn item ->
      {:ok, binary} = Item.encode(item)
      binary
    end)
    <<2::size(8), byte_size(items)::size(32)>> <> items
  end
end
