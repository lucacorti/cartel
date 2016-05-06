defprotocol Cartel.Message.Encoder do
  @moduledoc """
  Protocol for encoding messages in wire format
  """
  @fallback_to_any true

  @doc """
  Encode the message in a format suitable for wire transmission
  """
  def encode(message)
end

defimpl Cartel.Message.Encoder, for: Any do
  def encode(_) do
    {:error, "Cartel.Message.Encoder not implemented for this type."}
  end
end
