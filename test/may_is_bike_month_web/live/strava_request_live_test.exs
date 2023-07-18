defmodule MayIsBikeMonthWeb.StravaRequestLiveTest do
  use MayIsBikeMonthWeb.ConnCase

  import Phoenix.LiveViewTest
  import MayIsBikeMonth.StravaRequestsFixtures

  describe "Index" do
    test "lists all strava_requests", %{conn: conn} do
      strava_request_fixture()
      {:ok, _index_live, html} = live(conn, ~p"/strava_requests")

      assert html =~ "Listing Strava requests"
    end
  end
end
