defmodule Cartel.Message.Apns do
  @moduledoc """
  Apple APNS Binary API message

  `items`: `List` of `Cartel.Message.Apns.Item`

  At a minimum, `id` and `payload` items must be present.

  For more details on the format see the [Binary Provider API](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Appendixes/BinaryProviderAPI.html#//apple_ref/doc/uid/TP40008194-CH106-SW5)
  section of Apple [Local and Remote Notification Programming Guide](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/Introduction.html)
  """

  @type t :: %__MODULE__{}

  defstruct [items: []]
end

defimpl Cartel.Message, for: Cartel.Message.Apns do
  alias Cartel.Message.Apns.Item

  def serialize(message) do
    items = Enum.map_join(message.items, fn item ->
      {:ok, binary} = Item.encode(item)
      binary
    end)
    <<2::size(8), byte_size(items)::size(32)>> <> items
  end

  def update_token(message, token) do
    items = message.items
    |> Enum.filter(fn item -> item.id !== Item.device_token end)
    |> List.insert_at(0, %Item{id: Item.device_token, data: token})

    %{message | items: items}
  end
end
