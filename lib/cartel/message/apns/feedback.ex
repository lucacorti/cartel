defmodule Cartel.Message.Apns.Feedback do
  @moduledoc """
  APNS legacy binary interface feedback message format
  """

  defstruct [time: nil, token: nil]
end
