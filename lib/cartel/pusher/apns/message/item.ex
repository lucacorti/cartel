defmodule Cartel.Pusher.Apns.Message.Item do
  defstruct [:id, :data]

  @device_token 1
  def device_token, do: @device_token

  @payload 2
  def payload, do: @payload

  @notification_identifier 3
  def notification_identifier, do: @notification_identifier

  @expiration_date 4
  def expiration_date, do: @expiration_date

  @priority 5
  def priority, do: @priority

  @priority_immediately 10
  def priority_immediately, do: @priority_immediately

  @priority_when_convenient 5
  def priority_when_convenient, do: @priority_when_convenient

  def encode(item) do
    case item.id do
      @device_token ->
        {:ok, token} = Base.decode16(item.data, case: :mixed)
        {:ok, <<item.id::size(8), 32::size(16)>> <> token}
      @payload ->
        {:ok, payload} = Poison.encode(item.data)
        payload_size = byte_size(payload)
        {:ok, <<item.id::size(8), payload_size::size(16)>> <> payload}
      @notification_identifier ->
        {:ok, <<item.id::size(8), 4::size(16), item.data::size(32)>>}
      @expiration_date ->
        expiration_date = item.data
        if item.data == nil do
          expiration_date = 0
        end
        {:ok, <<item.id::size(8), 4::size(16), expiration_date::size(32)>>}
      @priority ->
        priority = item.data
        if priority == nil do
          priority = @priority_immediately
        end
        {:ok, <<item.id::size(8), 1::size(16), priority::size(32)>>}
    end
  end
end
