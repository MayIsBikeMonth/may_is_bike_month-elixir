defmodule MayIsBikeMonth.NumberFormatterTest do
  use ExUnit.Case, async: true

  alias MayIsBikeMonth.NumberFormatter

  describe "with_delimiter/2" do
    test "with 0" do
      assert NumberFormatter.with_delimiter(0.0) == "0"
      assert NumberFormatter.with_delimiter(0, precision: 1) == "0"
    end

    test "1000" do
      assert NumberFormatter.with_delimiter(1000.0) == "1,000"
      assert NumberFormatter.with_delimiter(1000.1) == "1,000"
      assert NumberFormatter.with_delimiter(1000.9) == "1,001"

      assert NumberFormatter.with_delimiter(1000.0, precision: 1) == "1,000"
      assert NumberFormatter.with_delimiter(1000.9, precision: 1) == "1,000.9"
    end
  end
end
