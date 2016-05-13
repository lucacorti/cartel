defmodule Cartel.Message.Gcm do
  @moduledoc """
  Google GCM message
  """
  @derive Poison.Encoder

  @type t :: %__MODULE__{}

  defstruct [:to, :data]
end

defimpl Cartel.Message, for: Cartel.Message.Gcm do
  def serialize(message) do
    Poison.encode(message)
  end

  def update_token(message, token) do
    %{message | to: token}
  end
end
