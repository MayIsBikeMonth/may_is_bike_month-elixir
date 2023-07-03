defmodule MayIsBikeMonthWeb.PageControllerTest do
  use MayIsBikeMonthWeb.ConnCase

  test "GET /", %{conn: conn} do
    MayIsBikeMonth.CompetitionsFixtures.competition_fixture()
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "May is Bike Month"
  end
end
