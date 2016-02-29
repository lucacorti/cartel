defprotocol Cartel.Message.Encoder do
  def encode(message)
end

defimpl Cartel.Message.Encoder, for: Any do
  def encode(message) do
    message
  end
end
