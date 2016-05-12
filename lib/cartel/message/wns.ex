defmodule Cartel.Message.Wns do
  @moduledoc """
  WNS message format
  """

  @type t :: %__MODULE__{}

  defstruct []
end

defimpl Cartel.Message, for: Cartel.Message.Wns do
  def serialize(message) do
    Poison.encode(message)
  end

  def update_token(message, _) do
    message
  end
end
