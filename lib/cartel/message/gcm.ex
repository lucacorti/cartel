defmodule Cartel.Message.Gcm do
  @moduledoc """
  Google GCM message

  For more details on the format see [Simple Downstream Messaging](https://developers.google.com/cloud-messaging/downstream)
  section of the [Google Cloud Messaging Documentation](https://developers.google.com/cloud-messaging/)
  """

  @typedoc """
  Google GCM message

  - `to`: recipient registration token
  - `data`: the notification payload
  """
  @type t :: %__MODULE__{to: String.t(), data: %{}}

  defstruct [:to, :data]
end

defimpl Cartel.Message, for: Cartel.Message.Gcm do
  def serialize(message) do
    Jason.encode!(message)
  end

  def update_token(message, token) do
    %{message | to: token}
  end
end
