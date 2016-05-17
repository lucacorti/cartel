defmodule Cartel.Message.Gcm do
  @moduledoc """
  Google GCM message

  - `to`: `String.t`, recipient registration token
  - `data`: `Map`, the notification payload

  For more details on the format see [Simple Downstream Messaging](https://developers.google.com/cloud-messaging/downstream)
  section of the [Google Cloud Messaging Documentation](https://developers.google.com/cloud-messaging/)
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
