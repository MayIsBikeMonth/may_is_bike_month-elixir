# https://nickjanetakis.com/blog/formatting-seconds-into-hh-mm-ss-with-elixir-and-python
defmodule MayIsBikeMonth.TimeFormatterTest do
  use ExUnit.Case, async: true

  alias MayIsBikeMonth.TimeFormatter

  describe "to_hh_mm_ss" do
    test "0" do
      assert TimeFormatter.to_hh_mm_ss(0) == "0:00"
    end

    test "to_hh_mm_ss/1 60" do
      assert TimeFormatter.to_hh_mm_ss(60) == "0:01"
    end

    test "to_hh_mm_ss/1 3661" do
      assert TimeFormatter.to_hh_mm_ss(3661) == "1:01"
    end
  end

  describe "duration_to_text" do
    test "0" do
      assert TimeFormatter.duration_to_text(0) == ""
    end

    test "duration_to_text/1 120" do
      assert TimeFormatter.duration_to_text(120) == "2 minutes"
    end

    test "duration_to_text/1 123" do
      assert TimeFormatter.duration_to_text(123) == "2 minutes, 3 seconds"
    end

    test "duration_to_text/1 3661" do
      assert TimeFormatter.duration_to_text(3661) == "1 hours, 1 minutes, 1 seconds"
    end
  end

  describe "format/2 (date, format)" do
    test "out_format: may 5" do
      assert TimeFormatter.format(~D[2023-05-05], "%b %-d") == "May 5"
    end
  end

  describe "format/2 (string, format)" do
    test "out_format: may 5" do
      assert TimeFormatter.format("2023-05-05", "%b %-d") == "May 5"
    end
  end

  describe "format/2 (datetime, format)" do
    test "out_format: strftime" do
      # Calendar.strftime/2 doesn't accept flags or %l (2023-6-27)
      assert TimeFormatter.format(~U[2023-06-25 20:29:00Z], "%-l:%M%P") == "8:29pm"

      assert TimeFormatter.format(~U[2023-06-25 20:29:00Z], "%Y-%-m-%-d@%-H:%M") ==
               "2023-6-25@20:29"
    end

    test "out_format: strftime in timezone PDT" do
      time = TimeFormatter.in_timezone(~U[2023-06-25 20:29:00Z], "America/Los_Angeles")
      assert Calendar.strftime(time, "%Z") == "PDT"
      assert TimeFormatter.format(time, "%Z") == "PDT"
      assert TimeFormatter.format(time, "%-l:%M%P %Z") == "1:29pm PDT"
    end

    test "out_format: extended" do
      time = TimeFormatter.in_timezone(~U[2023-06-24 20:29:00Z], "America/Chicago")
      assert TimeFormatter.format(time, :extended) == "2023-06-24 15:29:00 CDT"
    end

    test "out_format: strftime with timezone Nairobi" do
      time = TimeFormatter.in_timezone(~U[2023-06-25 20:29:00Z], "Africa/Nairobi")
      assert TimeFormatter.format(time, "%Z") == "EAT"
    end

    test "out_format: time_parser" do
      time = TimeFormatter.in_timezone(~U[2023-06-24 20:29:00Z], "Africa/Nairobi")
      assert TimeFormatter.format(time, :time_parser) == "Jun 24 11:29pm"
    end

    test "out_format: time_parser today" do
      time =
        DateTime.add(
          Timex.beginning_of_day(
            TimeFormatter.in_timezone(DateTime.utc_now(), "America/Los_Angeles")
          ),
          1,
          :hour
        )

      assert TimeFormatter.format(time, :time_parser) == "Today 1:00am"
    end

    test "out_format: time_parser yesterday" do
      time =
        DateTime.add(
          Timex.beginning_of_day(
            TimeFormatter.in_timezone(DateTime.utc_now(), "America/Los_Angeles")
          ),
          -4,
          :hour
        )

      assert TimeFormatter.format(time, :time_parser) == "Yesterday 8:00pm"
    end

    test "out_format: time_parser tomorrow" do
      time =
        DateTime.add(
          Timex.beginning_of_day(
            TimeFormatter.in_timezone(DateTime.utc_now(), "America/Los_Angeles")
          ),
          26,
          :hour
        )

      assert TimeFormatter.format(time, :time_parser) == "Tomorrow 2:00am"
    end

    test "out_format: time_parser next year" do
      time = TimeFormatter.in_timezone(~U[2024-06-25 20:29:00Z], "America/Chicago")
      assert TimeFormatter.format(time, :time_parser) == "2024-6-25"
    end
  end

  describe "timezone_selects" do
    test "includes the list" do
      tz_list = TimeFormatter.timezone_selects()
      first = Enum.at(tz_list, 0)
      assert first == {"Africa/Abidjan - GMT (+00:00:00)", "Africa/Abidjan"}
      assert length(tz_list) > 580
    end
  end
end
