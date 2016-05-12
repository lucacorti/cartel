defmodule Cartel.Message.Apns.Feedback do
  @moduledoc """
  APNS legacy binary interface feedback message format
  """

  defstruct [time: nil, token: nil]

  @record_size 38
  def record_size, do: @record_size
end
