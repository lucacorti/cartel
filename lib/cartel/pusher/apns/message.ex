defmodule Cartel.Pusher.Apns.Message do
  alias Cartel.Message.Encoder

  defstruct [items: []]

  @behaviour Cartel.Message

  @apns_no_errors 0
  @apns_processing_error 1
  @apns_missing_token 2
  @apns_missing_topic 3
  @apns_missing_payload 4
  @apns_invalid_token_size 5
  @apns_invalid_topic_size 6
  @apns_invalid_payload_size 7
  @apns_invalid_token 8
  @apns_shutdown 10
  @apns_unknown_error 255

  def deserialize(binary) do
    case binary do
      <<8::size(8), status::size(8), identifier::size(32)>> ->
        case status do
          @apns_no_errors ->
            {:error, identifier, status, "No errors encountered"}
          @apns_processing_error ->
            {:error, identifier, status, "Processing error"}
          @apns_missing_token ->
            {:error, identifier, status, "Missing device token"}
          @apns_missing_topic ->
            {:error, identifier, status, "Missing topic"}
          @apns_missing_payload ->
            {:error, identifier, status, "Missing payload"}
          @apns_invalid_token_size ->
            {:error, identifier, status, "Invalid token size"}
          @apns_invalid_topic_size ->
            {:error, identifier, status, "Invalid topic size"}
          @apns_invalid_payload_size ->
            {:error, identifier, status, "Invalid payload_size"}
          @apns_invalid_token ->
            {:error, identifier, status, "Invalid token"}
          @apns_shutdown ->
            {:error, identifier, status, "Shutdown"}
          @apns_unknown_error ->
            {:error, identifier, status, "None (unknown)"}
        end
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
