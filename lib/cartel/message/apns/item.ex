defmodule Cartel.Message.Apns.Item do
  @moduledoc """
  APNS legacy binary interface item submessage format
  """

  alias Cartel.Message.Apns.Item

  @type t :: %__MODULE__{}

  defstruct [:id, :data]

  @device_token 1

  @doc """
  Returns the `device_token` item binary protocol id
  """
  @spec device_token :: Integer.t
  def device_token, do: @device_token

  @payload 2

  @doc """
  Returns the `payload` item binary protocol id
  """
  @spec payload :: Integer.t
  def payload, do: @payload


  @notification_identifier 3

  @doc """
  Returns the `notification_identifier` item binary protocol id
  """
  @spec notification_identifier :: Integer.t
  def notification_identifier, do: @notification_identifier

  @expiration_date 4

  @doc """
  Returns the `expiration_date` item binary protocol id
  """
  @spec expiration_date :: Integer.t
  def expiration_date, do: @expiration_date

  @priority 5

  @doc """
  Returns the `priority` item binary protocol id
  """
  @spec priority :: Integer.t
  def priority, do: @priority


  @priority_immediately 10

  @doc """
  Returns the `priority_immediately` item binary protocol value
  """
  @spec priority_immediately :: Integer.t
  def priority_immediately, do: @priority_immediately

  @priority_when_convenient 5


  @doc """
  Returns the `priority_when_convenient` item binary protocol value
  """
  @spec priority_when_convenient :: Integer.t
  def priority_when_convenient, do: @priority_when_convenient

  @doc """
  Encodes the `item` to binary format
  """
  @spec encode(t) :: {:ok, <<>>}
  def encode(item = %Item{id: @device_token}) do
    {:ok, token} = Base.decode16(item.data, case: :mixed)
    {:ok, <<item.id::size(8), 32::size(16)>> <> token}
  end

  def encode(item = %Item{id: @payload}) do
    {:ok, msg_payload} = Poison.encode(item.data)
    payload_size = byte_size(msg_payload)
    {:ok, <<item.id::size(8), payload_size::size(16)>> <> msg_payload}
  end

  def encode(item = %Item{id: @notification_identifier}) do
    {:ok, <<item.id::size(8), 4::size(16), item.data::size(32)>>}
  end

  def encode(item = %Item{id: @expiration_date, data: nil}) do
    {:ok, <<item.id::size(8), 4::size(16), 0::size(32)>>}
  end

  def encode(item = %Item{id: @expiration_date}) do
    {:ok, <<item.id::size(8), 4::size(16), item.data::size(32)>>}
  end

  def encode(item = %Item{id: @priority, data: nil}) do
    {:ok, <<item.id::size(8), 1::size(16), @priority_immediately::size(32)>>}
  end

  def encode(item = %Item{id: @priority}) do
    {:ok, <<item.id::size(8), 1::size(16), item.data::size(32)>>}
  end
end
