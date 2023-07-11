defmodule MayIsBikeMonth.NumberFormatter do
  @moduledoc """
  NumberFormatter handles some basic number formatting.
  """
  import Number.Delimit

  # Trims trailing
  def with_delimiter(number), do: with_delimiter(number, precision: 0)

  def with_delimiter(number, precision: precision) do
    precision = precision || 0
    Regex.replace(~r/\.0+\z/, number_to_delimited(number, precision: precision), "")
  end
end
