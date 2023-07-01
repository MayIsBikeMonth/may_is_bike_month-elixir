defmodule MayIsBikeMonth.TimeFormatter do
  @moduledoc """
  TimeFormatter handles some basic time formatting.
  Right now it's a grab bag, it will get more organized eventually
  """

  # Currently, Calendar.strftime/1 doesn't support some of the formatting we need (specifically %l)
  # When that changes, we can switch from using timex to using the standard lib
  def format(%DateTime{} = time, :time_parser), do: time_parser_format(time)
  def format(%DateTime{} = time, :extended), do: format(time, "%Y-%m-%d %H:%M:%S %Z")

  def format(%DateTime{} = time, out_format) do
    cond do
      String.match?(out_format, ~r/%Z/) ->
        # Calendar returns tz abbreviation correctly here, unlike Timex, so replace it
        format(time, Regex.replace(~r/%Z/, out_format, Calendar.strftime(time, "%Z")))

      String.match?(out_format, ~r/%/) ->
        # Timex requires that the format have at least one transformation - check for %, which signifies a strftime
        Timex.format!(time, out_format, :strftime)

      true ->
        # This doesn't have any strfime formatting. Could be the format was originall %Z (which was already replaced)
        out_format
    end
  end

  defp time_parser_format(time) do
    today_start = Timex.beginning_of_day(in_timezone(DateTime.utc_now(), time.time_zone))
    yesterday_start = DateTime.add(today_start, -1, :day)
    tomorrow_end = DateTime.add(today_start, 2, :day)

    cond do
      DateTime.compare(time, yesterday_start) == :gt &&
          DateTime.compare(time, tomorrow_end) == :lt ->
        prefix =
          if DateTime.compare(time, today_start) == :lt do
            "Yesterday"
          else
            if DateTime.compare(time, DateTime.add(today_start, 1, :day)) == :lt do
              "Today"
            else
              "Tomorrow"
            end
          end

        "#{prefix} #{format(time, "%-l:%M%P")}"

      format(time, "%Y") == format(today_start, "%Y") ->
        format(time, "%b %-d %-l:%M%P")

      true ->
        format(time, "%Y-%-m-%-d")
    end
  end

  def to_hh_mm_ss(0), do: "0:00"

  def to_hh_mm_ss(seconds) do
    units = [3600, 60]

    [h | t] =
      Enum.map_reduce(units, seconds, fn unit, val -> {div(val, unit), rem(val, unit)} end)
      |> elem(0)

    {h, t} = if length(t) == 0, do: {0, [h]}, else: {h, t}

    "#{h}:#{t |> Enum.map_join(":", fn x -> x |> Integer.to_string() |> String.pad_leading(2, "0") end)}"
  end

  def duration_to_text(seconds) do
    arr_t = array_times(seconds)

    [
      Enum.at(arr_t, 0) != 0 && "#{Enum.at(arr_t, 0)} hours",
      Enum.at(arr_t, 1) != 0 && "#{Enum.at(arr_t, 1)} minutes",
      Enum.at(arr_t, 2) != 0 && "#{Enum.at(arr_t, 2)} seconds"
    ]
    |> Enum.drop_while(&match?(false, &1))
    |> Enum.join(", ")
    |> String.trim_trailing(", ")
    # I HAVE NO IDEA WHY THIS APPEARS
    |> String.trim_trailing(", false")
  end

  defp array_times(seconds) do
    units = [3600, 60, 1]

    # [h | t] =
    Enum.map_reduce(units, seconds, fn unit, val -> {div(val, unit), rem(val, unit)} end)
    |> elem(0)
  end

  def in_timezone(time, timezone) do
    DateTime.shift_zone(time, timezone)
    |> elem(1)
  end

  def timezone_selects do
    now = DateTime.utc_now()

    Tzdata.zone_list()
    |> Enum.map(fn zone ->
      tzinfo = Timex.Timezone.get(zone, now)
      # added in v3.78
      offset = Timex.TimezoneInfo.format_offset(tzinfo)
      label = "#{tzinfo.full_name} - #{tzinfo.abbreviation} (#{offset})"

      {label, tzinfo.full_name}
    end)
    |> Enum.uniq()
  end
end
