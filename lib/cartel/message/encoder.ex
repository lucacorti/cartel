defprotocol Cartel.Message.Encoder do
  @fallback_to_any true
  def encode(message)
end

defimpl Cartel.Message.Encoder, for: Any do
  def encode(_) do
    {:error, "Cartel.Message.Encoder protocol not implemented this type."}
  end
end
