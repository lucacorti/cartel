defmodule Cartel.Message.Apns.Feedback do
  @moduledoc """
  APNS binary interface feedback message format

  `time`: UNIX Timestamp since the `token` is not valid anymore
  `token`: token of the recipient

  For more details on the format see the [Binary Provider API](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Appendixes/BinaryProviderAPI.html#//apple_ref/doc/uid/TP40008194-CH106-SW5)
  section of Apple [Local and Remote Notification Programming Guide](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/Introduction.html)
  """

  @type t :: %__MODULE__{}

  defstruct [time: nil, token: nil]

  @record_size 38

  @doc """
  Returns the fixed APNS feedback record size
  """
  @spec record_size :: Integer.t
  def record_size, do: @record_size

  @doc """
  Returns feedback record decoded to `Cartel.Message.Apns.Feedback`
  """
  @spec decode!(binary) :: t
  def decode!(<<time::size(32), 32::size(16), token::size(256)>>) do
    %__MODULE__{time: time, token: token}
  end
end
