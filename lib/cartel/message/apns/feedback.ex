defmodule Cartel.Message.Apns.Feedback do
  @moduledoc """
  APNS legacy binary interface feedback message format
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
