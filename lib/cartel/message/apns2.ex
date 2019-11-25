defmodule Cartel.Message.Apns2 do
  @moduledoc """
  Apple APNS Provider API interface message

  For more details on the format see the [APNS Provider API](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/APNsProviderAPI.html#//apple_ref/doc/uid/TP40008194-CH101-SW1)
  section of Apple [Local and Remote Notification Programming Guide](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/Introduction.html)
  """

  @typedoc """
  Apple APNS Provider API interface message

  - `token`: token of the recipient
  - `id`: canonical form UUID for delivery errors
  - `expiration`: UNIX timestamp of notification expiration
  - `priority`: `priority_immediately/0` or `priority_when_convenient/0`
  - `topic`: If your certificate includes multiple topics
  - `payload`: the notification payload

  At a minimum, `id` and `payload` items must be populated.
  """
  @type t :: %__MODULE__{token: String.t, id: String.t, expiration: Integer.t,
                         priority: Integer.t, topic: String.t, payload: %{}}

  defstruct [
    token: nil, id: nil, expiration: 0, priority: 10, topic: nil, payload: %{}
  ]

  @priority_immediately 10

  @doc """
  Returns the `priority_immediately` protocol value
  """
  @spec priority_immediately :: Integer.t
  def priority_immediately, do: @priority_immediately

  @priority_when_convenient 5

  @doc """
  Returns the `priority_when_convenient` protocol value
  """
  @spec priority_when_convenient :: Integer.t
  def priority_when_convenient, do: @priority_when_convenient
end

defimpl Cartel.Message, for: Cartel.Message.Apns2 do
  def serialize(message) do
    Jason.encode!(message.payload)
  end

  def update_token(message, token) do
    %{message | token: token}
  end
end
