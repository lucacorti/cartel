defmodule Cartel.Message.Apns do
  @moduledoc """
  APNS binary interface message format
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
